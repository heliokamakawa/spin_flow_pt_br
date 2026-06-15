import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_fabricante.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';

class RepositorioFabricante {
  IDAOFabricante get _dao => GetIt.I<IDAOFabricante>();

  Future<List<Fabricante>> listar() => _dao.buscarTodos();

  Future<Fabricante?> buscarPorNome(String nome) => _dao.buscarPorNome(nome);

  Future<void> salvar(Fabricante fabricante) => _dao.salvar(fabricante);

  Future<void> excluir(int id) => _dao.excluir(id);
}
