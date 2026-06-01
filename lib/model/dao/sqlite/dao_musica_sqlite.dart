import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;
import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_categoria_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_video_aula.dart';

class DAOMusicaSQLite implements IDAOMusica {
  static const _tabela = 'musica';
  static const _tabelaCategoria = 'musica_categoria';
  static const _tabelaVideo = 'musica_video_aula';

  @override
  Future<List<ModeloMusica>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT m.id, m.nome, m.descricao, m.artista_id, m.ativo,
             a.nome AS artista_nome
      FROM musica m
      LEFT JOIN artista_banda a ON m.artista_id = a.id
      ORDER BY m.nome
    ''');
    return maps.map(_mapParaModelo).toList();
  }

  @override
  Future<List<ModeloMusica>> buscarAtivas() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT m.id, m.nome, m.descricao, m.artista_id, m.ativo,
             a.nome AS artista_nome
      FROM musica m
      LEFT JOIN artista_banda a ON m.artista_id = a.id
      WHERE m.ativo = 1
      ORDER BY m.nome
    ''');
    return maps.map(_mapParaModelo).toList();
  }

  @override
  Future<ModeloMusica?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery(
      '''
      SELECT m.id, m.nome, m.descricao, m.artista_id, m.ativo,
             a.nome AS artista_nome
      FROM musica m
      LEFT JOIN artista_banda a ON m.artista_id = a.id
      WHERE m.id = ?
    ''',
      [id],
    );
    return maps.isEmpty ? null : _mapParaModelo(maps.first);
  }

  @override
  Future<int> salvar(ModeloMusica musica) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': musica.nome,
      'descricao': musica.descricao,
      'artista_id': musica.artistaId,
      'categoria_ids': '[]',
      'video_aula_ids': '[]',
      'ativo': musica.ativo ? 1 : 0,
    };
    if (musica.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [musica.id]);
      return musica.id!;
    }
    return db.insert(_tabela, dados);
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<ModeloCategoriaMusica>> buscarCategorias(int musicaId) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery(
      '''
      SELECT c.id, c.nome, c.descricao, c.ativa
      FROM categoria_musica c
      JOIN $_tabelaCategoria mc ON mc.categoria_id = c.id
      WHERE mc.musica_id = ?
      ORDER BY c.nome
    ''',
      [musicaId],
    );
    return maps
        .map(
          (m) => ModeloCategoriaMusica(
            id: m['id'] as int?,
            nome: (m['nome'] as String?) ?? '',
            descricao: (m['descricao'] as String?) ?? '',
            ativa: ((m['ativa'] as int?) ?? 1) == 1,
          ),
        )
        .toList();
  }

  @override
  Future<void> atualizarCategorias(int musicaId, List<int> categoriaIds) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      await txn.delete(
        _tabelaCategoria,
        where: 'musica_id = ?',
        whereArgs: [musicaId],
      );
      for (final cId in categoriaIds) {
        await txn.insert(_tabelaCategoria, {
          'musica_id': musicaId,
          'categoria_id': cId,
        });
      }
    });
  }

  @override
  Future<List<ModeloVideoAula>> buscarVideos(int musicaId) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery(
      '''
      SELECT v.id, v.nome, v.link_video, v.ativo
      FROM video_aula v
      JOIN $_tabelaVideo mv ON mv.video_aula_id = v.id
      WHERE mv.musica_id = ?
      ORDER BY v.nome
    ''',
      [musicaId],
    );
    return maps
        .map(
          (m) => ModeloVideoAula(
            id: m['id'] as int?,
            nome: (m['nome'] as String?) ?? '',
            linkVideo: (m['link_video'] as String?) ?? '',
            ativo: ((m['ativo'] as int?) ?? 1) == 1,
          ),
        )
        .toList();
  }

  @override
  Future<void> atualizarVideos(int musicaId, List<int> videoIds) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      await txn.delete(
        _tabelaVideo,
        where: 'musica_id = ?',
        whereArgs: [musicaId],
      );
      for (final vId in videoIds) {
        await txn.insert(_tabelaVideo, {
          'musica_id': musicaId,
          'video_aula_id': vId,
        });
      }
    });
  }

  @override
  Future<void> adicionarVideo(int musicaId, int videoId) async {
    final db = await ConexaoSQLite.database;
    await db.insert(_tabelaVideo, {
      'musica_id': musicaId,
      'video_aula_id': videoId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  ModeloMusica _mapParaModelo(Map<String, dynamic> map) {
    return ModeloMusica(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      artistaId: map['artista_id'] as int?,
      nomeArtista: (map['artista_nome'] as String?) ?? '',
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }
}
