import 'package:spin_flow/domain/modelo/avaliacao_musica_detalhe.dart';

abstract class IDAOAvaliacaoMusica {
  Future<Map<int, int>> buscarAvaliacoesAluno(int alunoId, List<int> musicaIds);
  Future<List<AvaliacaoMusicaDetalhe>> buscarTodasComDetalhes(int alunoId);
  Future<void> salvar(int alunoId, int musicaId, int nota);
}
