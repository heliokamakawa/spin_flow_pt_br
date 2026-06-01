import 'package:spin_flow/model/gestao_administrativa/modelo_bike.dart';

abstract class IDAOBike {
  Future<List<ModeloBike>> buscarTodos();
  Future<ModeloBike?> buscarPorId(int id);
  Future<void> salvar(ModeloBike bike);
  Future<void> excluir(int id);
}
