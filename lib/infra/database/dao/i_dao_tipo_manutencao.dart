import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';

abstract class IDAOTipoManutencao {
  Future<List<TipoManutencao>> buscarTodos();
  Future<void> salvar(TipoManutencao tipo);
  Future<void> excluir(int id);
}
