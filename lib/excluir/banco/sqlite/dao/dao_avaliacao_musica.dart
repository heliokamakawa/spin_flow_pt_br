import 'package:sqflite/sqflite.dart';
import 'package:spin_flow/excluir/banco/sqlite/conexao.dart';

class DAOAvaliacaoMusica {
  static const String _tabela = 'avaliacao_musica';

  Future<Map<int, int>> buscarPorAlunoEMusicas({
    required int alunoId,
    required List<int> musicaIds,
  }) async {
    if (musicaIds.isEmpty) return {};

    final db = await ConexaoSQLite.database;
    final placeholders = List.filled(musicaIds.length, '?').join(', ');
    final maps = await db.query(
      _tabela,
      columns: ['musica_id', 'nota'],
      where: 'aluno_id = ? AND musica_id IN ($placeholders)',
      whereArgs: [alunoId, ...musicaIds],
    );

    return {
      for (final map in maps) _toInt(map['musica_id']): _toInt(map['nota']),
    };
  }

  Future<void> salvar({
    required int alunoId,
    required int musicaId,
    required int nota,
  }) async {
    final db = await ConexaoSQLite.database;
    final notaNormalizada = nota.clamp(1, 5);
    await db.insert(_tabela, {
      'aluno_id': alunoId,
      'musica_id': musicaId,
      'nota': notaNormalizada,
      'atualizado_em': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
