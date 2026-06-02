import 'package:spin_flow/domain/modelo/posicao_bike.dart';

abstract class IDAOPosicaoBike {
  Future<List<PosicaoBike>> buscarTodos();
}
