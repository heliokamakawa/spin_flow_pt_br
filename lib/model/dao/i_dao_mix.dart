import 'package:spin_flow/model/gestao_aula/modelo_mix.dart';

abstract class IDAOMix {
  Future<List<ModeloMix>> buscarTodos();
  Future<ModeloMix?> buscarPorId(int id);
  Future<int> salvar(ModeloMix mix);
  Future<void> excluir(int id);
}
