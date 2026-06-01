import 'package:spin_flow/model/dao/i_dao_artista_banda.dart';
import 'package:spin_flow/model/gestao_aula/modelo_artista_banda.dart';

class ServicoArtistaBanda {
  final IDAOArtistaBanda _dao;

  ServicoArtistaBanda({required IDAOArtistaBanda dao}) : _dao = dao;

  Future<List<ModeloArtistaBanda>> listarAtivos() => _dao.buscarAtivos();

  Future<String?> salvar(ModeloArtistaBanda artista) async {
    if (artista.nome.trim().isEmpty) return 'Nome é obrigatório.';
    await _dao.salvar(artista);
    return null;
  }

  Future<void> excluir(int id) => _dao.excluir(id);
}
