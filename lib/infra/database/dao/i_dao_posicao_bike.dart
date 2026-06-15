import 'package:spin_flow/domain/modelo/posicao_bike.dart';

abstract class IDAOPosicaoBike {
  Future<List<PosicaoBike>> buscarTodos();
  Future<PosicaoBike?> buscarPorBikeId(int bikeId);
  Future<void> atribuirBike(int fila, int coluna, int? bikeId);
}
