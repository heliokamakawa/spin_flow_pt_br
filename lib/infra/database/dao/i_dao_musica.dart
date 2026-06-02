import 'package:spin_flow/domain/modelo/categoria_musica.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/domain/modelo/video_aula.dart';

abstract class IDAOMusica {
  Future<List<Musica>> buscarTodos();
  Future<List<Musica>> buscarAtivas();
  Future<Musica?> buscarPorId(int id);
  Future<int> salvar(Musica musica);
  Future<void> excluir(int id);

  Future<List<CategoriaMusica>> buscarCategorias(int musicaId);
  Future<void> atualizarCategorias(int musicaId, List<int> categoriaIds);

  Future<List<VideoAula>> buscarVideos(int musicaId);
  Future<void> atualizarVideos(int musicaId, List<int> videoIds);
  Future<void> adicionarVideo(int musicaId, int videoId);
}
