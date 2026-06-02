import 'package:spin_flow/domain/modelo/mix.dart';

abstract class IDAOMix {
  Future<List<Mix>> buscarTodos();
  Future<Mix?> buscarPorId(int id);
  Future<int> salvar(Mix mix);
  Future<void> excluir(int id);
}
