import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/model/gestao_aula/modelo_posicao_bike.dart';

class DAOPosicaoBikeSQLite implements IDAOPosicaoBike {
  @override
  Future<List<ModeloPosicaoBike>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT pb.fila, pb.coluna, pb.bike_id, b.nome AS bike_nome
      FROM posicao_bike pb
      LEFT JOIN bike b ON pb.bike_id = b.id
    ''');
    return maps.map((m) {
      return ModeloPosicaoBike(
        fila: (m['fila'] as int?) ?? 0,
        coluna: (m['coluna'] as int?) ?? 0,
        bikeId: m['bike_id'] as int?,
        bikeNome: (m['bike_nome'] as String?) ?? '',
      );
    }).toList();
  }
}
