import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_artista_banda.dart';
import 'package:spin_flow/domain/dominio/dominio_artista_banda.dart';
import 'package:spin_flow/domain/modelo/artista_banda.dart';

class ControladorArtistaBanda {
  final _repositorio = RepositorioArtistaBanda();

  Future<List<ArtistaBanda>> listar() => _repositorio.listarAtivos();

  Future<ResultadoOperacao> salvar(ArtistaBanda modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioArtistaBanda(modelo);
    final erroRegras = dominio.validarRegras();
    if (erroRegras != null) return ResultadoOperacao.falha(mensagemErro: erroRegras);
    await _repositorio.salvar(modelo);
    return ResultadoOperacao.sucesso();
  }

  Future<ResultadoOperacao> excluir(int id) async {
    try {
      await _repositorio.excluir(id);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }
}
