import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_bike.dart';
import 'package:spin_flow/domain/modelo/bike.dart';

class DAOBikeSQLite implements IDAOBike {
  static const _tabela = 'bike';

  @override
  Future<List<Bike>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapear).toList();
  }

  @override
  Future<Bike?> buscarPorId(int id) async {
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
  Future<Bike?> buscarPorNome(String nome) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery(
      'SELECT * FROM $_tabela WHERE LOWER(nome) = LOWER(?) LIMIT 1',
      [nome.trim()],
    );
    if (maps.isEmpty) return null;
    return _mapear(maps.first);
  }

  @override
  Future<int> salvar(Bike bike) async {
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
      return bike.id!;
    } else {
      return await db.insert(_tabela, dados);
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativa': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Bike _mapear(Map<String, dynamic> map) => Bike(
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
