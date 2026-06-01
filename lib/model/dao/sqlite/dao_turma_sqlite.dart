import 'dart:convert';

import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_turma.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';

class DAOTurmaSQLite implements IDAOTurma {
  static const _tabela = 'turma';
  static const _tabelaDiaSemana = 'turma_dia_semana';

  @override
  Future<List<ModeloTurma>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    final turmas = <ModeloTurma>[];
    for (final map in maps) {
      turmas.add(await _mapear(map));
    }
    return turmas;
  }

  @override
  Future<ModeloTurma?> buscarPorId(int id) async {
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
  Future<void> salvar(ModeloTurma turma) async {
    final db = await ConexaoSQLite.database;
    await _validarConflitoHorario(turma);

    final dados = {
      'nome': turma.nome,
      'descricao': '',
      'dias_semana': jsonEncode(
        turma.diasSemana.map((dia) => dia.dbValue).toList(),
      ),
      'horario_inicio': turma.horarioInicio,
      'duracao_minutos': turma.duracaoMinutos,
      'sala_id': turma.salaId,
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

  Future<ModeloTurma> _mapear(Map<String, dynamic> map) async {
    final id = map['id'] as int?;
    final dias = id == null
        ? _parseDias((map['dias_semana'] as String?) ?? '[]')
        : await _buscarDiasSemana(id, (map['dias_semana'] as String?) ?? '[]');
    return ModeloTurma(
      id: id,
      nome: (map['nome'] as String?) ?? '',
      horarioInicio: (map['horario_inicio'] as String?) ?? '',
      duracaoMinutos: (map['duracao_minutos'] as int?) ?? 0,
      diasSemana: dias,
      salaId: (map['sala_id'] as int?) ?? 0,
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }

  Future<void> _validarConflitoHorario(ModeloTurma turma) async {
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
      final dias = await _buscarDiasSemana(
        idExistente,
        (map['dias_semana'] as String?) ?? '[]',
      );
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

  List<DiaSemana> _parseDias(String valor) {
    try {
      final decoded = jsonDecode(valor);
      if (decoded is! List) return [];
      return decoded.map((item) => DiaSemana.fromDbValue('$item')).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<DiaSemana>> _buscarDiasSemana(
    int turmaId,
    String diasLegadosJson,
  ) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabelaDiaSemana,
      where: 'turma_id = ?',
      whereArgs: [turmaId],
      orderBy: 'id',
    );

    if (maps.isNotEmpty) {
      return maps
          .map(
            (map) =>
                DiaSemana.fromDbValue((map['dia_semana'] as String?) ?? ''),
          )
          .toList();
    }

    return _parseDias(diasLegadosJson);
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
