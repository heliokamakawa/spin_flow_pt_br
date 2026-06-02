import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_manutencao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/bike.dart';
import 'package:spin_flow/domain/modelo/manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';

class RepositorioManutencao {
  IDAOManutencao    get _daoManu  => GetIt.I<IDAOManutencao>();
  IDAOBike          get _daoBike  => GetIt.I<IDAOBike>();
  IDAOTipoManutencao get _daoTipo => GetIt.I<IDAOTipoManutencao>();

  Future<List<Manutencao>>    listar()      => _daoManu.buscarTodos();
  Future<List<Bike>>          listarBikes() => _daoBike.buscarTodos();
  Future<List<TipoManutencao>> listarTipos() => _daoTipo.buscarTodos();

  Future<void> salvar(Manutencao m) => _daoManu.salvar(m);

  Future<void> excluir(int id) => _daoManu.excluir(id);
}
