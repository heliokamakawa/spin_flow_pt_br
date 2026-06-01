import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_aula/modelo_artista_banda.dart';
import 'package:spin_flow/model/gestao_aula/modelo_categoria_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_video_aula.dart';
import 'package:spin_flow/model/servico/servico_artista_banda.dart';
import 'package:spin_flow/model/servico/servico_musica.dart';

class ControladorMusica {
  final ServicoMusica _servico;
  final ServicoArtistaBanda _servicoArtista;

  ControladorMusica({
    required ServicoMusica servico,
    required ServicoArtistaBanda servicoArtista,
  }) : _servico = servico,
       _servicoArtista = servicoArtista;

  Future<List<ModeloMusica>> listar() => _servico.listarAtivas();

  Future<List<ModeloArtistaBanda>> listarArtistas() =>
      _servicoArtista.listarAtivos();

  Future<List<ModeloCategoriaMusica>> listarCategorias() =>
      _servico.listarCategorias();

  Future<ResultadoOperacao> salvar(ModeloMusica musica) async {
    final erro = await _servico.salvar(musica);
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }

  Future<ResultadoOperacao> salvarComCategorias(
    ModeloMusica musica,
    List<String> nomesCategoria,
  ) async {
    final erro = await _servico.salvarComCategorias(musica, nomesCategoria);
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }

  Future<void> excluir(int id) => _servico.excluir(id);

  Future<List<ModeloCategoriaMusica>> buscarCategorias(int musicaId) =>
      _servico.buscarCategorias(musicaId);

  Future<void> atualizarCategorias(int musicaId, List<String> nomes) =>
      _servico.atualizarCategorias(musicaId, nomes);

  Future<List<ModeloVideoAula>> buscarVideos(int musicaId) =>
      _servico.buscarVideos(musicaId);

  Future<ResultadoOperacao> adicionarVideoAula(
    int musicaId,
    String link,
  ) async {
    final erro = await _servico.adicionarVideoAula(musicaId, link);
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }

  Future<void> atualizarVideos(int musicaId, List<String> links) =>
      _servico.atualizarVideos(musicaId, links);
}
