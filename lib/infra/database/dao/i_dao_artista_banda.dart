import 'package:spin_flow/domain/modelo/artista_banda.dart';

abstract class IDAOArtistaBanda {
  Future<List<ArtistaBanda>> buscarTodos();
  Future<List<ArtistaBanda>> buscarAtivos();
  Future<ArtistaBanda?> buscarPorId(int id);
  Future<int> salvar(ArtistaBanda artista);
  Future<void> excluir(int id);
}
