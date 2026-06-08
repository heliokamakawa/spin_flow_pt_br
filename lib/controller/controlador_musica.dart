import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_artista_banda.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_musica.dart';
import 'package:spin_flow/domain/dominio/dominio_musica.dart';
import 'package:spin_flow/domain/modelo/artista_banda.dart';
import 'package:spin_flow/domain/modelo/categoria_musica.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/domain/modelo/video_aula.dart';

class ControladorMusica {
  final _repositorio = RepositorioMusica();
  final _repositorioArtista = RepositorioArtistaBanda();

  Future<List<Musica>> listar() => _repositorio.listarAtivas();
  Future<List<ArtistaBanda>> listarArtistas() =>
      _repositorioArtista.listarAtivos();
  Future<List<CategoriaMusica>> listarCategorias() =>
      _repositorio.listarCategorias();

  Future<ResultadoOperacao> salvar(DominioMusica dominio) async {
    final erro = dominio.validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return ResultadoOperacao.sucesso();
  }

  Future<ResultadoOperacao> salvarComCategorias(
    DominioMusica dominio,
    List<String> nomes,
  ) async {
    final erro = dominio.validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvarComCategorias(dominio.modelo, nomes);
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

  Future<List<CategoriaMusica>> buscarCategorias(int musicaId) =>
      _repositorio.buscarCategorias(musicaId);

  Future<void> atualizarCategorias(int musicaId, List<String> nomes) =>
      _repositorio.atualizarCategorias(musicaId, nomes);

  Future<List<VideoAula>> buscarVideos(int musicaId) =>
      _repositorio.buscarVideos(musicaId);

  Future<ResultadoOperacao> adicionarVideoAula(int musicaId, String link) async {
    final url = link.trim();
    final erro = VideoAula(nome: url, linkVideo: url).validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.adicionarVideoAula(musicaId, url);
    return ResultadoOperacao.sucesso();
  }

  Future<void> atualizarVideos(int musicaId, List<String> links) =>
      _repositorio.atualizarVideos(musicaId, links);
}
