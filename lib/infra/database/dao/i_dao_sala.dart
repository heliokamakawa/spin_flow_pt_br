import 'package:spin_flow/domain/modelo/sala.dart';

abstract class IDAOSala {
  Future<List<Sala>> buscarTodos();
  Future<Sala?> buscarPorId(int id);
  Future<void> salvar(Sala sala);
  Future<void> excluir(int id);
}
