import 'package:spin_flow/domain/modelo/manutencao.dart';

abstract class IDAOManutencao {
  Future<List<Manutencao>> buscarTodos();
  Future<Manutencao?> buscarPorId(int id);
  Future<void> salvar(Manutencao manutencao);
  Future<void> excluir(int id);
  Future<Set<int>> buscarBikeIdsEmManutencaoAtiva();
  Future<Manutencao?> buscarManutencaoAtivaPorBikeId(int bikeId);
  Future<Map<int, String>> buscarDescricoesAtivas();
}
