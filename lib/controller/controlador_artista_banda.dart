import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_artista_banda.dart';
import 'package:spin_flow/domain/dominio/dominio_artista_banda.dart';
import 'package:spin_flow/domain/modelo/artista_banda.dart';

class ControladorArtistaBanda {
  final _repositorio = RepositorioArtistaBanda();

  Future<List<ArtistaBanda>> listar() => _repositorio.listarAtivos();

  Future<ResultadoOperacao> salvar(DominioArtistaBanda dominio) async {
    final erro = dominio.validarParaSalvar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => _repositorio.excluir(id);
}
