import 'package:get_it/get_it.dart';
import 'package:spin_flow/domain/modelo/bike.dart';
import 'package:spin_flow/domain/modelo/posicao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_posicao_bike.dart';

class RepositorioBike {
  IDAOBike get _dao => GetIt.I<IDAOBike>();
  IDAOPosicaoBike get _daoPosicao => GetIt.I<IDAOPosicaoBike>();

  Future<List<Bike>> listar() => _dao.buscarTodos();

  Future<Bike?> buscarPorNome(String nome) => _dao.buscarPorNome(nome);

  Future<int> salvar(Bike bike) => _dao.salvar(bike);

  Future<void> excluir(int id) => _dao.excluir(id);

  Future<List<PosicaoBike>> listarPosicoes() => _daoPosicao.buscarTodos();

  Future<PosicaoBike?> buscarPosicaoDaBike(int bikeId) =>
      _daoPosicao.buscarPorBikeId(bikeId);

  Future<void> atribuirPosicao(int fila, int coluna, int? bikeId) =>
      _daoPosicao.atribuirBike(fila, coluna, bikeId);
}
