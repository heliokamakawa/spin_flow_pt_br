import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_sala.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';

class DAOSalaSQLite implements IDAOSala {
  static const String _tabela = 'sala';

  @override
  Future<List<ModeloSala>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapear).toList();
  }

  @override
  Future<ModeloSala?> buscarPorId(int id) async {
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
  Future<void> salvar(ModeloSala sala) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': sala.nome,
      'numero_filas': sala.numeroFilas,
      'numero_colunas': sala.numeroColunas,
      'posicao_professora': sala.posicaoProfessora,
      'ativa': sala.ativa ? 1 : 0,
    };

    if (sala.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [sala.id]);
    } else {
      await db.insert(_tabela, dados);
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativa': 0}, where: 'id = ?', whereArgs: [id]);
  }

  ModeloSala _mapear(Map<String, dynamic> map) {
    final colunas = (map['numero_colunas'] as int?) ?? 1;
    final posicao = (map['posicao_professora'] as int?) ?? 1;
    final fila = colunas > 0 ? (posicao - 1) ~/ colunas + 1 : 1;
    final coluna = colunas > 0 ? (posicao - 1) % colunas + 1 : 1;

    return ModeloSala(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      numeroFilas: (map['numero_filas'] as int?) ?? 1,
      numeroColunas: colunas,
      filaProfessora: fila,
      colunaProfessora: coluna,
      ativa: ((map['ativa'] as int?) ?? 1) == 1,
    );
  }
}
