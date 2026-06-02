import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma.dart';
import 'package:spin_flow/domain/modelo/turma.dart';

class DAOTurmaSQLite implements IDAOTurma {
  static const _tabela = 'turma';
  static const _tabelaDiaSemana = 'turma_dia_semana';

  @override
  Future<List<Turma>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    final turmas = <Turma>[];
    for (final map in maps) {
      turmas.add(await _mapear(map));
    }
    return turmas;
  }

  @override
  Future<Turma?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _mapear(maps.first);
  }

  @override
  Future<void> salvar(Turma turma) async {
    final db = await ConexaoSQLite.database;
    await _validarConflitoHorario(turma);

    final dados = {
      'nome': turma.nome,
      'descricao': '',
      'horario_inicio': turma.horarioInicio,
      'duracao_minutos': turma.duracaoMinutos,
      'sala_id': turma.salaId,
      'professora_id': turma.professoraId,
      'ativo': turma.ativo ? 1 : 0,
    };

    int turmaId;
    if (turma.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [turma.id]);
      turmaId = turma.id!;
    } else {
      turmaId = await db.insert(_tabela, dados);
    }

    await db.delete(
      _tabelaDiaSemana,
      where: 'turma_id = ?',
      whereArgs: [turmaId],
    );
    for (final dia in turma.diasSemana) {
      await db.insert(_tabelaDiaSemana, {
        'turma_id': turmaId,
        'dia_semana': dia.dbValue,
      });
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<Turma> _mapear(Map<String, dynamic> map) async {
    final id = map['id'] as int?;
    final dias = id == null ? <DiaSemana>[] : await _buscarDiasSemana(id);
    return Turma(
      id: id,
      nome: (map['nome'] as String?) ?? '',
      horarioInicio: (map['horario_inicio'] as String?) ?? '',
      duracaoMinutos: (map['duracao_minutos'] as int?) ?? 0,
      diasSemana: dias,
      salaId: (map['sala_id'] as int?) ?? 0,
      professoraId: map['professora_id'] as int?,
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }

  Future<void> _validarConflitoHorario(Turma turma) async {
    if (!turma.ativo) return;

    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'sala_id = ? AND ativo = 1',
      whereArgs: [turma.salaId],
    );

    for (final map in maps) {
      final idExistente = map['id'] as int?;
      if (turma.id != null && idExistente == turma.id) continue;

      if (idExistente == null) continue;
      final dias = await _buscarDiasSemana(idExistente);
      final haDiaEmComum = dias
          .toSet()
          .intersection(turma.diasSemana.toSet())
          .isNotEmpty;
      if (!haDiaEmComum) continue;

      final horarioExistente = (map['horario_inicio'] as String?) ?? '';
      final duracaoExistente = (map['duracao_minutos'] as int?) ?? 0;
      if (_sobrepoeHorario(
        turma.horarioInicio,
        turma.duracaoMinutos,
        horarioExistente,
        duracaoExistente,
      )) {
        throw Exception('Conflito de horario na mesma sala.');
      }
    }
  }

  Future<List<DiaSemana>> _buscarDiasSemana(int turmaId) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabelaDiaSemana,
      where: 'turma_id = ?',
      whereArgs: [turmaId],
      orderBy: 'id',
    );

    return maps
        .map(
          (map) => DiaSemana.fromDbValue((map['dia_semana'] as String?) ?? ''),
        )
        .toList();
  }

  bool _sobrepoeHorario(String h1, int d1, String h2, int d2) {
    final i1 = _minutosDoDia(h1);
    final i2 = _minutosDoDia(h2);
    final f1 = i1 + d1;
    final f2 = i2 + d2;
    return i1 < f2 && i2 < f1;
  }

  int _minutosDoDia(String horario) {
    final partes = horario.split(':');
    if (partes.length != 2) return 0;
    final hora = int.tryParse(partes[0]) ?? 0;
    final minuto = int.tryParse(partes[1]) ?? 0;
    return hora * 60 + minuto;
  }
}
