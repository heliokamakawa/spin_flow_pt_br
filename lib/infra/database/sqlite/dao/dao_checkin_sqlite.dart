import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_checkin.dart';
import 'package:spin_flow/domain/modelo/checkin.dart';

class DAOCheckinSQLite implements IDAOCheckin {
  static const _tabela = 'checkin';

  @override
  Future<List<Checkin>> buscarAtivosPorTurmaData(
    int turmaId,
    DateTime data,
  ) async {
    final db = await ConexaoSQLite.database;
    final chave = _chaveData(data);
    final maps = await db.rawQuery(
      '''
      SELECT c.id, c.aluno_id, c.turma_id, c.data, c.fila, c.coluna, c.ativo,
             a.nome AS aluno_nome
      FROM checkin c
      LEFT JOIN aluno a ON c.aluno_id = a.id
      WHERE c.turma_id = ?
        AND c.ativo = 1
        AND substr(c.data, 1, 10) = ?
    ''',
      [turmaId, chave],
    );
    return maps.map(_mapear).toList();
  }

  @override
  Future<int> salvar(Checkin checkin) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'aluno_id': checkin.alunoId,
      'turma_id': checkin.turmaId,
      'data': checkin.data.toIso8601String(),
      'fila': checkin.fila,
      'coluna': checkin.coluna,
      'ativo': checkin.ativo ? 1 : 0,
    };
    if (checkin.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [checkin.id]);
      return checkin.id!;
    }
    return db.insert(_tabela, dados);
  }

  @override
  Future<bool> existeAtivoPorAluno(
    int alunoId,
    int turmaId,
    DateTime data,
  ) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      columns: ['id'],
      where:
          'aluno_id = ? AND turma_id = ? AND ativo = 1 AND substr(data, 1, 10) = ?',
      whereArgs: [alunoId, turmaId, _chaveData(data)],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  @override
  Future<bool> existeAtivoPorPosicao(
    int turmaId,
    DateTime data,
    int fila,
    int coluna,
  ) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      columns: ['id'],
      where:
          'turma_id = ? AND ativo = 1 AND fila = ? AND coluna = ? AND substr(data, 1, 10) = ?',
      whereArgs: [turmaId, fila, coluna, _chaveData(data)],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  @override
  Future<List<Checkin>> buscarAtivosPorAlunoDia(
    int alunoId,
    DateTime data,
  ) async {
    final db = await ConexaoSQLite.database;
    final chave = _chaveData(data);
    final maps = await db.rawQuery(
      '''
      SELECT c.id, c.aluno_id, c.turma_id, c.data, c.fila, c.coluna, c.ativo,
             a.nome AS aluno_nome
      FROM checkin c
      LEFT JOIN aluno a ON c.aluno_id = a.id
      WHERE c.aluno_id = ?
        AND c.ativo = 1
        AND substr(c.data, 1, 10) = ?
      ''',
      [alunoId, chave],
    );
    return maps.map(_mapear).toList();
  }

  @override
  Future<void> cancelar(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Checkin _mapear(Map<String, dynamic> m) => Checkin(
    id: m['id'] as int?,
    alunoId: (m['aluno_id'] as int?) ?? 0,
    turmaId: (m['turma_id'] as int?) ?? 0,
    data: DateTime.tryParse((m['data'] as String?) ?? '') ?? DateTime.now(),
    fila: (m['fila'] as int?) ?? 0,
    coluna: (m['coluna'] as int?) ?? 0,
    ativo: ((m['ativo'] as int?) ?? 1) == 1,
    nomeAluno: (m['aluno_nome'] as String?) ?? '',
  );

  String _chaveData(DateTime data) => DateTime(
    data.year,
    data.month,
    data.day,
  ).toIso8601String().substring(0, 10);
}
