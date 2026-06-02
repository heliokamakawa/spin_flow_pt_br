import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_avaliacao_musica.dart';

class DAOAvaliacaoMusicaSQLite implements IDAOAvaliacaoMusica {
  static const _tabela = 'avaliacao_musica';

  @override
  Future<Map<int, int>> buscarAvaliacoesAluno(
    int alunoId,
    List<int> musicaIds,
  ) async {
    if (musicaIds.isEmpty) return {};
    final db = await ConexaoSQLite.database;
    final placeholders = musicaIds.map((_) => '?').join(',');
    final rows = await db.rawQuery(
      'SELECT musica_id, nota FROM $_tabela WHERE aluno_id = ? AND musica_id IN ($placeholders)',
      [alunoId, ...musicaIds],
    );
    return {
      for (final row in rows)
        (row['musica_id'] as int): (row['nota'] as int),
    };
  }

  @override
  Future<void> salvar(int alunoId, int musicaId, int nota) async {
    final db = await ConexaoSQLite.database;
    await db.rawInsert(
      '''
      INSERT OR REPLACE INTO $_tabela (aluno_id, musica_id, nota, atualizado_em)
      VALUES (?, ?, ?, ?)
      ''',
      [alunoId, musicaId, nota, DateTime.now().toIso8601String()],
    );
  }
}
