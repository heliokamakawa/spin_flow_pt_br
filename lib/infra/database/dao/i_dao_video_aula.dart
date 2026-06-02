import 'package:spin_flow/domain/modelo/video_aula.dart';

abstract class IDAOVideoAula {
  Future<List<VideoAula>> buscarTodos();
  Future<VideoAula?> buscarPorId(int id);
  Future<VideoAula?> buscarPorLink(String linkVideo);
  Future<int> salvar(VideoAula video);
  Future<void> excluir(int id);
}
