import 'package:spin_flow/model/gestao_aula/modelo_artista_banda.dart';

abstract class IDAOArtistaBanda {
  Future<List<ModeloArtistaBanda>> buscarTodos();
  Future<List<ModeloArtistaBanda>> buscarAtivos();
  Future<ModeloArtistaBanda?> buscarPorId(int id);
  Future<int> salvar(ModeloArtistaBanda artista);
  Future<void> excluir(int id);
}
