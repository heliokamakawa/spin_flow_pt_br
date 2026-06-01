import 'package:spin_flow/model/gestao_aula/modelo_posicao_bike.dart';

abstract class IDAOPosicaoBike {
  Future<List<ModeloPosicaoBike>> buscarTodos();
}
