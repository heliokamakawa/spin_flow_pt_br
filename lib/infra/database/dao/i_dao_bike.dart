import 'package:spin_flow/domain/modelo/bike.dart';

abstract class IDAOBike {
  Future<List<Bike>> buscarTodos();
  Future<Bike?> buscarPorId(int id);
  Future<Bike?> buscarPorNome(String nome);
  Future<int> salvar(Bike bike);
  Future<void> excluir(int id);
}
