import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma_mix.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/musica_checkin.dart';

class DAOTurmaMixSQLite implements IDAOTurmaMix {
  @override
  Future<MixCheckin?> buscarMixDaTurma(int turmaId, DateTime data) async {
    final db = await ConexaoSQLite.database;
    final dataIso = data.toIso8601String().substring(0, 10);

    // Busca o mix ativo mais recente para a turma na data
    final mixRows = await db.rawQuery(
      '''
      SELECT tm.mix_id, m.nome
      FROM turma_mix tm
      JOIN mix m ON m.id = tm.mix_id AND m.ativo = 1
      WHERE tm.turma_id = ?
        AND tm.ativo = 1
        AND DATE(tm.data_inicio) <= DATE(?)
        AND DATE(tm.data_fim)   >= DATE(?)
      ORDER BY tm.id DESC
      LIMIT 1
      ''',
      [turmaId, dataIso, dataIso],
    );

    if (mixRows.isEmpty) return null;

    final mixId = mixRows.first['mix_id'] as int;
    final nomeMix = mixRows.first['nome'] as String;

    // Busca as músicas do mix ordenadas por posição
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

  @override
  Future<MixCheckin?> buscarMixPorId(int mixId) async {
    final db = await ConexaoSQLite.database;
    final mixRows = await db.rawQuery(
      'SELECT id, nome FROM mix WHERE id = ? AND ativo = 1 LIMIT 1',
      [mixId],
    );
    if (mixRows.isEmpty) return null;
    final nomeMix = mixRows.first['nome'] as String;

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
}
