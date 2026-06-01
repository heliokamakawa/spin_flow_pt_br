import 'package:spin_flow/model/gestao_aula/modelo_video_aula.dart';

abstract class IDAOVideoAula {
  Future<List<ModeloVideoAula>> buscarTodos();
  Future<ModeloVideoAula?> buscarPorId(int id);
  Future<ModeloVideoAula?> buscarPorLink(String linkVideo);
  Future<int> salvar(ModeloVideoAula video);
  Future<void> excluir(int id);
}
