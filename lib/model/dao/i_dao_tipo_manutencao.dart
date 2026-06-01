import 'package:spin_flow/model/gestao_administrativa/modelo_tipo_manutencao.dart';

abstract class IDAOTipoManutencao {
  Future<List<ModeloTipoManutencao>> buscarTodos();
  Future<void> salvar(ModeloTipoManutencao tipo);
  Future<void> excluir(int id);
}
