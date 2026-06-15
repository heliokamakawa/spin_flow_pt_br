import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_mix.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/mix_repertorio_professora.dart';
import 'package:spin_flow/domain/modelo/musica_checkin.dart';
import 'package:spin_flow/domain/modelo/musica_repertorio_professora.dart';
import 'package:spin_flow/domain/modelo/video_aula.dart';

class DAOMixSQLite implements IDAOMix {
  static const _tabela = 'mix';
  static const _tabelaMixMusica = 'mix_musica';

  @override
  Future<List<Mix>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'ativo = 1', orderBy: 'nome');
    final List<Mix> lista = [];
    for (final map in maps) {
      lista.add(await _mapParaModelo(map));
    }
    return lista;
  }

  @override
  Future<Mix?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _mapParaModelo(maps.first);
  }

  @override
  Future<int> salvar(Mix mix) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': mix.nome,
      'descricao': mix.descricao,
      'ativo': mix.ativo ? 1 : 0,
    };

    late int mixId;
    if (mix.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [mix.id]);
      mixId = mix.id!;
    } else {
      mixId = await db.insert(_tabela, dados);
    }

    await db.transaction((txn) async {
      await txn.delete(
        _tabelaMixMusica,
        where: 'mix_id = ?',
        whereArgs: [mixId],
      );
      for (int i = 0; i < mix.posicoes.length; i++) {
        final musicaId = mix.posicoes[i];
        if (musicaId != null) {
          await txn.insert(_tabelaMixMusica, {
            'mix_id': mixId,
            'musica_id': musicaId,
            'posicao': i + 1,
          });
        }
      }
    });

    return mixId;
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<MixCheckin?> buscarMixDaTurma(int turmaId) async {
    final db = await ConexaoSQLite.database;
    final mixRows = await db.rawQuery(
      '''
      SELECT m.id AS mix_id, m.nome
      FROM turma t
      JOIN mix m ON m.id = t.mix_id AND m.ativo = 1
      WHERE t.id = ?
      ''',
      [turmaId],
    );
    if (mixRows.isEmpty) return null;
    final mixId = mixRows.first['mix_id'] as int;
    final nomeMix = mixRows.first['nome'] as String;
    return _buscarMusicasDeMix(mixId, nomeMix);
  }

  @override
  Future<MixCheckin?> buscarMixPorId(int mixId) async {
    final db = await ConexaoSQLite.database;
    final rows = await db.rawQuery(
      'SELECT id, nome FROM mix WHERE id = ? AND ativo = 1 LIMIT 1',
      [mixId],
    );
    if (rows.isEmpty) return null;
    return _buscarMusicasDeMix(mixId, rows.first['nome'] as String);
  }

  @override
  Future<MixRepertorioProfessora?> buscarMixComMediasPorId(int mixId) async {
    final db = await ConexaoSQLite.database;
    final rows = await db.rawQuery(
      'SELECT id, nome FROM mix WHERE id = ? AND ativo = 1 LIMIT 1',
      [mixId],
    );
    if (rows.isEmpty) return null;
    final nomeMix = rows.first['nome'] as String;

    final musicaRows = await db.rawQuery(
      '''
      SELECT mm.posicao,
             mu.id          AS musica_id,
             mu.nome        AS musica_nome,
             COALESCE(ab.nome, '') AS artista_nome,
             AVG(am.nota)   AS media_avaliacao,
             COUNT(am.nota) AS total_avaliadores
      FROM mix_musica mm
      JOIN musica mu ON mu.id = mm.musica_id AND mu.ativo = 1
      LEFT JOIN artista_banda ab ON ab.id = mu.artista_id
      LEFT JOIN avaliacao_musica am ON am.musica_id = mu.id
      WHERE mm.mix_id = ?
      GROUP BY mm.posicao, mu.id, mu.nome, artista_nome
      ORDER BY mm.posicao
      ''',
      [mixId],
    );

    final videoRows = await db.rawQuery(
      '''
      SELECT mva.musica_id, va.id AS va_id, va.nome AS va_nome, va.link_video
      FROM musica_video_aula mva
      JOIN video_aula va ON va.id = mva.video_aula_id AND va.ativo = 1
      WHERE mva.musica_id IN (SELECT musica_id FROM mix_musica WHERE mix_id = ?)
        AND (va.link_video LIKE 'http://%' OR va.link_video LIKE 'https://%')
      ORDER BY mva.musica_id, va.nome
      ''',
      [mixId],
    );
    final Map<int, List<VideoAula>> videosPorMusica = {};
    for (final vr in videoRows) {
      final mId = vr['musica_id'] as int;
      videosPorMusica.putIfAbsent(mId, () => []).add(VideoAula(
        id: vr['va_id'] as int?,
        nome: vr['va_nome'] as String,
        linkVideo: vr['link_video'] as String,
      ));
    }

    final musicas = musicaRows.map((r) {
      final media = r['media_avaliacao'];
      final musicaId = r['musica_id'] as int;
      return MusicaRepertorioProfessora(
        musicaId: musicaId,
        posicao: r['posicao'] as int,
        nome: r['musica_nome'] as String,
        nomeArtista: r['artista_nome'] as String,
        mediaAvaliacao: media != null ? (media as num).toDouble() : null,
        totalAvaliadores: (r['total_avaliadores'] as int?) ?? 0,
        videos: videosPorMusica[musicaId] ?? [],
      );
    }).toList();

    return MixRepertorioProfessora(mixId: mixId, nomeMix: nomeMix, musicas: musicas);
  }

  Future<MixCheckin> _buscarMusicasDeMix(int mixId, String nomeMix) async {
    final db = await ConexaoSQLite.database;
    final musicaRows = await db.rawQuery(
      '''
      SELECT mm.posicao, mu.id AS musica_id, mu.nome AS musica_nome,
             COALESCE(ab.nome, '') AS artista_nome
      FROM mix_musica mm
      JOIN musica mu ON mu.id = mm.musica_id AND mu.ativo = 1
      LEFT JOIN artista_banda ab ON ab.id = mu.artista_id
      WHERE mm.mix_id = ?
      ORDER BY mm.posicao
      ''',
      [mixId],
    );
    final musicas = musicaRows
        .map((row) => MusicaCheckin(
              musicaId: row['musica_id'] as int,
              posicao: row['posicao'] as int,
              nome: row['musica_nome'] as String,
              nomeArtista: row['artista_nome'] as String,
            ))
        .toList();
    return MixCheckin(mixId: mixId, nomeMix: nomeMix, musicas: musicas);
  }

  Future<Mix> _mapParaModelo(Map<String, dynamic> map) async {
    final mixId = map['id'] as int?;
    final posicoes = List<int?>.filled(Mix.totalSlots, null);

    if (mixId != null) {
      final db = await ConexaoSQLite.database;
      final slots = await db.query(
        _tabelaMixMusica,
        where: 'mix_id = ?',
        whereArgs: [mixId],
        orderBy: 'posicao',
      );
      for (final slot in slots) {
        final pos = (slot['posicao'] as int?) ?? 0;
        final musicaId = slot['musica_id'] as int?;
        if (pos >= 1 && pos <= Mix.totalSlots && musicaId != null) {
          posicoes[pos - 1] = musicaId;
        }
      }
    }

    return Mix(
      id: mixId,
      nome: (map['nome'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      posicoes: posicoes,
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }
}
