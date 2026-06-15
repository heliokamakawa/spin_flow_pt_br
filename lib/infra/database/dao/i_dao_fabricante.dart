import 'package:spin_flow/domain/modelo/fabricante.dart';

abstract class IDAOFabricante {
  Future<List<Fabricante>> buscarTodos();
  Future<Fabricante?> buscarPorNome(String nome);
  Future<void> salvar(Fabricante fabricante);
  Future<void> excluir(int id);
}
