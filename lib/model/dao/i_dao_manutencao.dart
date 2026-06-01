import 'package:spin_flow/model/gestao_administrativa/modelo_manutencao.dart';

abstract class IDAOManutencao {
  Future<List<ModeloManutencao>> buscarTodos();
  Future<ModeloManutencao?> buscarPorId(int id);
  Future<void> salvar(ModeloManutencao manutencao);
  Future<void> excluir(int id);
  Future<Set<int>> buscarBikeIdsEmManutencaoAtiva();
  Future<ModeloManutencao?> buscarManutencaoAtivaPorBikeId(int bikeId);
}
