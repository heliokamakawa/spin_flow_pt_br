import 'package:spin_flow/domain/modelo/avaliacao_musica_detalhe.dart';
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
  Future<List<AvaliacaoMusicaDetalhe>> buscarTodasComDetalhes(
    int alunoId,
  ) async {
    final db = await ConexaoSQLite.database;
    final rows = await db.rawQuery(
      '''
      SELECT am.musica_id, m.nome AS musica_nome,
             COALESCE(ab.nome, '') AS artista_nome,
             am.nota
      FROM avaliacao_musica am
      JOIN musica m ON am.musica_id = m.id
      LEFT JOIN artista_banda ab ON m.artista_id = ab.id
      WHERE am.aluno_id = ?
      ORDER BY am.nota DESC, m.nome ASC
      ''',
      [alunoId],
    );
    return rows
        .map(
          (r) => AvaliacaoMusicaDetalhe(
            musicaId: r['musica_id'] as int,
            nomeMusica: (r['musica_nome'] as String?) ?? '',
            nomeArtista: (r['artista_nome'] as String?) ?? '',
            nota: r['nota'] as int,
          ),
        )
        .toList();
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
