import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_sala.dart';
import 'package:spin_flow/domain/modelo/sala.dart';

class RepositorioSala {
  IDAOSala get _dao => GetIt.I<IDAOSala>();

  Future<List<Sala>> listar() => _dao.buscarTodos();
  Future<Sala?> buscarPorId(int id) => _dao.buscarPorId(id);

  Future<void> salvar(Sala sala) => _dao.salvar(sala);

  Future<void> excluir(int id) => _dao.excluir(id);
}
