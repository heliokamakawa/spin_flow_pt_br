import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';

abstract class IDAOSala {
  Future<List<ModeloSala>> buscarTodos();
  Future<ModeloSala?> buscarPorId(int id);
  Future<void> salvar(ModeloSala sala);
  Future<void> excluir(int id);
}
