import 'package:spin_flow/domain/modelo/aula_realizada.dart';
import 'package:spin_flow/domain/modelo/registro_historico_aula.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aula_realizada.dart';
import 'package:spin_flow/infra/database/sqlite/conexao.dart';

class DAOAulaRealizadaSQLite implements IDAOAulaRealizada {
  static const _tabela = 'aula_realizada';

  @override
  Future<int> contarPorAlunoNoPeriodo(
    int alunoId,
    DateTime inicio,
    DateTime fim,
  ) async {
    final db = await ConexaoSQLite.database;
    final inicioStr = _chaveData(inicio);
    final fimStr = _chaveData(fim);
    final resultado = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM $_tabela
      WHERE aluno_id = ?
        AND ativo = 1
        AND substr(data, 1, 10) >= ?
        AND substr(data, 1, 10) <= ?
      ''',
      [alunoId, inicioStr, fimStr],
    );
    return (resultado.first['total'] as int?) ?? 0;
  }

  @override
  Future<AulaRealizada?> buscarUltima(int alunoId) async {
    final db = await ConexaoSQLite.database;
    final rows = await db.rawQuery(
      '''
      SELECT id, aluno_id, turma_id, data, ativo
      FROM $_tabela
      WHERE aluno_id = ? AND ativo = 1
      ORDER BY data DESC
      LIMIT 1
      ''',
      [alunoId],
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return AulaRealizada(
      id: r['id'] as int?,
      alunoId: r['aluno_id'] as int,
      turmaId: r['turma_id'] as int,
      data: DateTime.tryParse((r['data'] as String?) ?? '') ?? DateTime.now(),
      ativo: ((r['ativo'] as int?) ?? 1) == 1,
    );
  }

  @override
  Future<void> salvar(AulaRealizada aula) async {
    final db = await ConexaoSQLite.database;
    await db.rawInsert(
      '''
      INSERT OR IGNORE INTO $_tabela (aluno_id, turma_id, data, ativo)
      VALUES (?, ?, ?, ?)
      ''',
      [
        aula.alunoId,
        aula.turmaId,
        aula.data.toIso8601String(),
        aula.ativo ? 1 : 0,
      ],
    );
  }

  @override
  Future<List<RegistroHistoricoAula>> listarPorAluno(
    int alunoId, {
    DateTime? aPartirDe,
  }) async {
    final db = await ConexaoSQLite.database;

    final where = StringBuffer('ar.aluno_id = ? AND ar.ativo = 1');
    final args = <Object?>[alunoId];
    if (aPartirDe != null) {
      where.write(' AND substr(ar.data, 1, 10) >= ?');
      args.add(_chaveData(aPartirDe));
    }

    final rows = await db.rawQuery(
      '''
      SELECT ar.data AS data, t.nome AS nome_turma, t.horario_inicio AS horario
      FROM $_tabela ar
      JOIN turma t ON t.id = ar.turma_id
      WHERE $where
      ORDER BY ar.data DESC
      ''',
      args,
    );

    return rows.map((r) {
      return RegistroHistoricoAula(
        nomeTurma: (r['nome_turma'] as String?) ?? '',
        data: DateTime.tryParse((r['data'] as String?) ?? '') ?? DateTime.now(),
        horarioInicio: (r['horario'] as String?) ?? '',
        presente: true,
      );
    }).toList();
  }

  String _chaveData(DateTime data) =>
      DateTime(data.year, data.month, data.day)
          .toIso8601String()
          .substring(0, 10);
}
