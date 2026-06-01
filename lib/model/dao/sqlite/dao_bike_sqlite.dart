import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_bike.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_bike.dart';

class DAOBikeSQLite implements IDAOBike {
  static const _tabela = 'bike';

  @override
  Future<List<ModeloBike>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapear).toList();
  }

  @override
  Future<ModeloBike?> buscarPorId(int id) async {
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
  Future<void> salvar(ModeloBike bike) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': bike.nome,
      'numero_serie': bike.numeroSerie,
      'fabricante_id': bike.fabricanteId,
      'data_cadastro': bike.dataCadastro.toIso8601String(),
      'ativa': bike.ativa ? 1 : 0,
    };
    if (bike.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [bike.id]);
    } else {
      await db.insert(_tabela, dados);
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativa': 0}, where: 'id = ?', whereArgs: [id]);
  }

  ModeloBike _mapear(Map<String, dynamic> map) => ModeloBike(
    id: map['id'] as int?,
    nome: (map['nome'] as String?) ?? '',
    numeroSerie: (map['numero_serie'] as String?) ?? '',
    fabricanteId: (map['fabricante_id'] as int?) ?? 0,
    dataCadastro:
        DateTime.tryParse((map['data_cadastro'] as String?) ?? '') ??
        DateTime.now(),
    ativa: ((map['ativa'] as int?) ?? 1) == 1,
  );
}
