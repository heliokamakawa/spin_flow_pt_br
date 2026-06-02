import 'dart:convert';

import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/infra/database/dao/i_dao_grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';

class DAOGrupoAlunosSQLite implements IDAOGrupoAlunos {
  static const String _tabela = 'grupo_alunos';
  static const String _tabelaGrupoAluno = 'grupo_aluno';

  final IDAOAluno daoAluno;

  const DAOGrupoAlunosSQLite({required this.daoAluno});

  @override
  Future<List<GrupoAlunos>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    final grupos = <GrupoAlunos>[];
    for (final map in maps) {
      grupos.add(await _mapear(map));
    }
    return grupos;
  }

  @override
  Future<GrupoAlunos?> buscarPorId(int id) async {
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
  Future<void> salvar(GrupoAlunos grupo) async {
    final db = await ConexaoSQLite.database;
    final alunoIds = grupo.alunos.map((aluno) => aluno.id).whereType<int>();
    final dados = {
      'nome': grupo.nome,
      'descricao': grupo.descricao,
      'aluno_ids': jsonEncode(alunoIds.toList()),
      'ativo': grupo.ativo ? 1 : 0,
    };

    int grupoId;
    if (grupo.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [grupo.id]);
      grupoId = grupo.id!;
    } else {
      grupoId = await db.insert(_tabela, dados);
    }

    await db.delete(
      _tabelaGrupoAluno,
      where: 'grupo_alunos_id = ?',
      whereArgs: [grupoId],
    );

    for (final alunoId in alunoIds.toSet()) {
      await db.insert(_tabelaGrupoAluno, {
        'grupo_alunos_id': grupoId,
        'aluno_id': alunoId,
      });
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<GrupoAlunos> _mapear(Map<String, dynamic> map) async {
    final id = map['id'] as int?;
    final alunos = id == null
        ? <Aluno>[]
        : await _buscarAlunos(id, (map['aluno_ids'] as String?) ?? '[]');

    return GrupoAlunos(
      id: id,
      nome: (map['nome'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      alunos: alunos,
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }

  Future<List<Aluno>> _buscarAlunos(
    int grupoId,
    String alunosLegadosJson,
  ) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabelaGrupoAluno,
      where: 'grupo_alunos_id = ?',
      whereArgs: [grupoId],
      orderBy: 'id',
    );

    final ids = maps.isNotEmpty
        ? maps.map((map) => map['aluno_id']).whereType<int>().toList()
        : _parseIds(alunosLegadosJson);
    final alunos = <Aluno>[];
    for (final id in ids) {
      final aluno = await daoAluno.buscarPorId(id);
      if (aluno != null) alunos.add(aluno);
    }
    return alunos;
  }

  List<int> _parseIds(String valor) {
    try {
      final decoded = jsonDecode(valor);
      if (decoded is List) {
        return decoded.whereType<num>().map((e) => e.toInt()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
