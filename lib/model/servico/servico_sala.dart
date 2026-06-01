import 'package:spin_flow/model/dao/i_dao_sala.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';

class ServicoSala {
  final IDAOSala daoSala;

  const ServicoSala({required this.daoSala});

  Future<List<ModeloSala>> listar() => daoSala.buscarTodos();

  Future<ModeloSala?> buscarPorId(int id) => daoSala.buscarPorId(id);

  Future<String?> salvar(ModeloSala sala) async {
    final erro = sala.validar();
    if (erro != null) return erro;
    await daoSala.salvar(sala);
    return null;
  }

  Future<void> excluir(int id) => daoSala.excluir(id);
}
