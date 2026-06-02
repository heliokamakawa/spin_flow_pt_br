import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_artista_banda.dart';
import 'package:spin_flow/domain/modelo/artista_banda.dart';

class RepositorioArtistaBanda {
  IDAOArtistaBanda get _dao => GetIt.I<IDAOArtistaBanda>();

  Future<List<ArtistaBanda>> listarAtivos() => _dao.buscarAtivos();

  Future<void> salvar(ArtistaBanda artista) => _dao.salvar(artista);

  Future<void> excluir(int id) => _dao.excluir(id);
}
