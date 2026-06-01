import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_fila_espera_checkin.dart';
import 'package:spin_flow/model/gestao_aula/modelo_fila_espera_checkin.dart';

class DAOFilaEsperaCheckinSQLite implements IDAOFilaEsperaCheckin {
  static const _tabela = 'fila_espera_checkin';

  @override
  Future<void> entrarNaFila(int alunoId, int turmaId, DateTime data) async {
    final db = await ConexaoSQLite.database;
    final jaEsta = await db.query(
      _tabela,
      columns: ['id'],
      where:
          'aluno_id = ? AND turma_id = ? AND ativo = 1 AND substr(data, 1, 10) = ?',
      whereArgs: [alunoId, turmaId, _chave(data)],
      limit: 1,
    );
    if (jaEsta.isNotEmpty) throw Exception('Aluno ja esta na fila.');
    await db.insert(_tabela, {
      'aluno_id': alunoId,
      'turma_id': turmaId,
      'data': data.toIso8601String(),
      'criado_em': DateTime.now().toIso8601String(),
      'ativo': 1,
    });
  }

  @override
  Future<int?> buscarPosicaoNaFila(
    int alunoId,
    int turmaId,
    DateTime data,
  ) async {
    final db = await ConexaoSQLite.database;
    final fila = await db.query(
      _tabela,
      columns: ['aluno_id'],
      where: 'turma_id = ? AND ativo = 1 AND substr(data, 1, 10) = ?',
      whereArgs: [turmaId, _chave(data)],
      orderBy: 'criado_em ASC',
    );
    final pos = fila.indexWhere((m) => m['aluno_id'] == alunoId);
    return pos == -1 ? null : pos + 1;
  }

  @override
  Future<int?> buscarIdDoAluno(int alunoId, int turmaId, DateTime data) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      columns: ['id'],
      where:
          'aluno_id = ? AND turma_id = ? AND ativo = 1 AND substr(data, 1, 10) = ?',
      whereArgs: [alunoId, turmaId, _chave(data)],
      limit: 1,
    );
    return maps.isEmpty ? null : maps.first['id'] as int?;
  }

  @override
  Future<ModeloFilaEsperaCheckin?> buscarPrimeiroAtivo(
    int turmaId,
    DateTime data,
  ) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'turma_id = ? AND ativo = 1 AND substr(data, 1, 10) = ?',
      whereArgs: [turmaId, _chave(data)],
      orderBy: 'criado_em ASC',
      limit: 1,
    );
    return maps.isEmpty ? null : _mapear(maps.first);
  }

  @override
  Future<void> sairDaFila(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  ModeloFilaEsperaCheckin _mapear(Map<String, dynamic> m) =>
      ModeloFilaEsperaCheckin(
        id: m['id'] as int?,
        alunoId: (m['aluno_id'] as int?) ?? 0,
        turmaId: (m['turma_id'] as int?) ?? 0,
        data: DateTime.tryParse((m['data'] as String?) ?? '') ?? DateTime.now(),
        criadoEm:
            DateTime.tryParse((m['criado_em'] as String?) ?? '') ??
            DateTime.now(),
        ativo: ((m['ativo'] as int?) ?? 1) == 1,
      );

  String _chave(DateTime data) => DateTime(
    data.year,
    data.month,
    data.day,
  ).toIso8601String().substring(0, 10);
}
