import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_checkin.dart';
import 'package:spin_flow/domain/modelo/checkin.dart';
import 'package:spin_flow/domain/modelo/frequencia_aluno.dart';
import 'package:spin_flow/domain/modelo/turma_aluno.dart';

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
             u.nome AS aluno_nome, a.instagram AS aluno_instagram
      FROM checkin c
      LEFT JOIN aluno a ON c.aluno_id = a.id
      LEFT JOIN usuario u ON u.aluno_id = c.aluno_id
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
             u.nome AS aluno_nome
      FROM checkin c
      LEFT JOIN usuario u ON u.aluno_id = c.aluno_id
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

  @override
  Future<List<FrequenciaAluno>> buscarFrequenciaPorTurma(
    int turmaId,
    DateTime inicio,
    DateTime fim,
  ) async {
    final db = await ConexaoSQLite.database;
    final chaveInicio = _chaveData(inicio);
    final chaveFim = _chaveData(fim);
    final maps = await db.rawQuery(
      '''
      SELECT
        c.aluno_id,
        u.nome AS nome_aluno,
        COUNT(c.id) AS total_checkins,
        (
          SELECT COUNT(DISTINCT substr(c2.data, 1, 10))
          FROM checkin c2
          WHERE c2.turma_id = ?
            AND c2.ativo = 1
            AND substr(c2.data, 1, 10) BETWEEN ? AND ?
        ) AS total_aulas
      FROM checkin c
      JOIN usuario u ON u.aluno_id = c.aluno_id
      WHERE c.turma_id = ?
        AND c.ativo = 1
        AND substr(c.data, 1, 10) BETWEEN ? AND ?
      GROUP BY c.aluno_id, u.nome
      HAVING COUNT(c.id) > 0
      ORDER BY u.nome
      ''',
      [turmaId, chaveInicio, chaveFim, turmaId, chaveInicio, chaveFim],
    );
    return maps
        .map(
          (m) => FrequenciaAluno(
            alunoId: (m['aluno_id'] as int?) ?? 0,
            nomeAluno: (m['nome_aluno'] as String?) ?? '',
            totalCheckins: (m['total_checkins'] as int?) ?? 0,
            totalAulas: (m['total_aulas'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  @override
  Future<List<FrequenciaAluno>> buscarAlunosPorProfessora(
    int professoraId,
  ) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery(
      '''
      SELECT c.aluno_id, u.nome AS nome_aluno, COUNT(c.id) AS total_checkins
      FROM checkin c
      JOIN turma t ON c.turma_id = t.id
      JOIN usuario u ON u.aluno_id = c.aluno_id
      WHERE t.professora_id = ? AND c.ativo = 1 AND t.ativo = 1
      GROUP BY c.aluno_id, u.nome
      ORDER BY total_checkins DESC
      ''',
      [professoraId],
    );
    return maps
        .map(
          (m) => FrequenciaAluno(
            alunoId: (m['aluno_id'] as int?) ?? 0,
            nomeAluno: (m['nome_aluno'] as String?) ?? '',
            totalCheckins: (m['total_checkins'] as int?) ?? 0,
            totalAulas: 0,
          ),
        )
        .toList();
  }

  @override
  Future<List<TurmaAluno>> buscarTurmasFrequentadasPorAluno(
    int alunoId,
    int professoraId,
  ) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery(
      '''
      SELECT t.id AS turma_id, t.nome, t.horario_inicio,
             COUNT(c.id) AS total_checkins
      FROM checkin c
      JOIN turma t ON c.turma_id = t.id
      WHERE c.aluno_id = ? AND t.professora_id = ?
        AND c.ativo = 1 AND t.ativo = 1
      GROUP BY t.id, t.nome, t.horario_inicio
      ORDER BY t.horario_inicio
      ''',
      [alunoId, professoraId],
    );
    return maps
        .map(
          (m) => TurmaAluno(
            turmaId: (m['turma_id'] as int?) ?? 0,
            nome: (m['nome'] as String?) ?? '',
            horarioInicio: (m['horario_inicio'] as String?) ?? '',
            totalCheckins: (m['total_checkins'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  @override
  Future<double?> calcularIdadeMediaTurma(int turmaId, DateTime data) async {
    final db = await ConexaoSQLite.database;
    final chave = _chaveData(data);
    final maps = await db.rawQuery(
      '''
      SELECT AVG((julianday('now') - julianday(a.data_nascimento)) / 365.25) AS idade_media
      FROM checkin c
      JOIN aluno a ON c.aluno_id = a.id
      WHERE c.turma_id = ? AND c.ativo = 1 AND substr(c.data, 1, 10) = ?
      ''',
      [turmaId, chave],
    );
    if (maps.isEmpty) return null;
    final v = maps.first['idade_media'];
    if (v == null) return null;
    return (v as num).toDouble();
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
    instagramAluno: (m['aluno_instagram'] as String?) ?? '',
  );

  String _chaveData(DateTime data) => DateTime(
    data.year,
    data.month,
    data.day,
  ).toIso8601String().substring(0, 10);
}
