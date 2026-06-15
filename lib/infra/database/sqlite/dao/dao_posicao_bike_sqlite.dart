import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/domain/modelo/posicao_bike.dart';

class DAOPosicaoBikeSQLite implements IDAOPosicaoBike {
  static const _tabela = 'posicao_bike';

  @override
  Future<List<PosicaoBike>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT pb.fila, pb.coluna, pb.bike_id, b.nome AS bike_nome
      FROM posicao_bike pb
      LEFT JOIN bike b ON pb.bike_id = b.id
      ORDER BY pb.fila, pb.coluna
    ''');
    return maps.map(_mapear).toList();
  }

  @override
  Future<PosicaoBike?> buscarPorBikeId(int bikeId) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT pb.fila, pb.coluna, pb.bike_id, b.nome AS bike_nome
      FROM posicao_bike pb
      LEFT JOIN bike b ON pb.bike_id = b.id
      WHERE pb.bike_id = ?
      LIMIT 1
    ''', [bikeId]);
    if (maps.isEmpty) return null;
    return _mapear(maps.first);
  }

  @override
  Future<void> atribuirBike(int fila, int coluna, int? bikeId) async {
    final db = await ConexaoSQLite.database;
    await db.update(
      _tabela,
      {'bike_id': bikeId},
      where: 'fila = ? AND coluna = ?',
      whereArgs: [fila, coluna],
    );
  }

  PosicaoBike _mapear(Map<String, dynamic> m) => PosicaoBike(
        fila: (m['fila'] as int?) ?? 0,
        coluna: (m['coluna'] as int?) ?? 0,
        bikeId: m['bike_id'] as int?,
        bikeNome: (m['bike_nome'] as String?) ?? '',
      );
}
