import 'package:spin_flow/model/gestao_aula/modelo_categoria_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_video_aula.dart';

abstract class IDAOMusica {
  Future<List<ModeloMusica>> buscarTodos();
  Future<List<ModeloMusica>> buscarAtivas();
  Future<ModeloMusica?> buscarPorId(int id);
  Future<int> salvar(ModeloMusica musica);
  Future<void> excluir(int id);

  Future<List<ModeloCategoriaMusica>> buscarCategorias(int musicaId);
  Future<void> atualizarCategorias(int musicaId, List<int> categoriaIds);

  Future<List<ModeloVideoAula>> buscarVideos(int musicaId);
  Future<void> atualizarVideos(int musicaId, List<int> videoIds);
  Future<void> adicionarVideo(int musicaId, int videoId);
}
