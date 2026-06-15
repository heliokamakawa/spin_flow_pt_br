import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';

class RepositorioTipoManutencao {
  IDAOTipoManutencao get _dao => GetIt.I<IDAOTipoManutencao>();

  Future<List<TipoManutencao>> listar() => _dao.buscarTodos();
  Future<TipoManutencao?> buscarPorId(int id) => _dao.buscarPorId(id);
  Future<void> salvar(TipoManutencao tipo) => _dao.salvar(tipo);
  Future<void> excluir(int id) => _dao.excluir(id);
}
