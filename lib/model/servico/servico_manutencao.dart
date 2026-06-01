import 'package:spin_flow/model/dao/i_dao_bike.dart';
import 'package:spin_flow/model/dao/i_dao_manutencao.dart';
import 'package:spin_flow/model/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_bike.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_manutencao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_tipo_manutencao.dart';

class ServicoManutencao {
  final IDAOManutencao daoManutencao;
  final IDAOBike daoBike;
  final IDAOTipoManutencao daoTipoManutencao;

  const ServicoManutencao({
    required this.daoManutencao,
    required this.daoBike,
    required this.daoTipoManutencao,
  });

  Future<List<ModeloManutencao>> listar() => daoManutencao.buscarTodos();
  Future<List<ModeloBike>> listarBikes() => daoBike.buscarTodos();
  Future<List<ModeloTipoManutencao>> listarTipos() =>
      daoTipoManutencao.buscarTodos();

  Future<String?> salvar(ModeloManutencao manutencao) async {
    final erro = manutencao.validar();
    if (erro != null) return erro;
    await daoManutencao.salvar(manutencao);
    return null;
  }

  Future<void> excluir(int id) => daoManutencao.excluir(id);
}
