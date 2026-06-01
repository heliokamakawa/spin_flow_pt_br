import 'package:spin_flow/model/dao/i_dao_categoria_musica.dart';
import 'package:spin_flow/model/dao/i_dao_musica.dart';
import 'package:spin_flow/model/dao/i_dao_video_aula.dart';
import 'package:spin_flow/model/gestao_aula/modelo_categoria_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_video_aula.dart';

class ServicoMusica {
  final IDAOMusica _daoMusica;
  final IDAOCategoriaMusica _daoCategoria;
  final IDAOVideoAula _daoVideo;

  ServicoMusica({
    required IDAOMusica daoMusica,
    required IDAOCategoriaMusica daoCategoria,
    required IDAOVideoAula daoVideo,
  }) : _daoMusica = daoMusica,
       _daoCategoria = daoCategoria,
       _daoVideo = daoVideo;

  Future<List<ModeloMusica>> listarAtivas() => _daoMusica.buscarAtivas();

  Future<List<ModeloCategoriaMusica>> listarCategorias() =>
      _daoCategoria.buscarAtivas();

  Future<String?> salvar(ModeloMusica musica) async {
    if (musica.nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (musica.artistaId == null) return 'Artista é obrigatório.';
    await _daoMusica.salvar(musica);
    return null;
  }

  /// Salva a música e atualiza as categorias em uma única operação.
  Future<String?> salvarComCategorias(
    ModeloMusica musica,
    List<String> nomesCategoria,
  ) async {
    if (musica.nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (musica.artistaId == null) return 'Artista é obrigatório.';
    final id = await _daoMusica.salvar(musica);
    await atualizarCategorias(id, nomesCategoria);
    return null;
  }

  Future<void> excluir(int id) => _daoMusica.excluir(id);

  Future<List<ModeloCategoriaMusica>> buscarCategorias(int musicaId) =>
      _daoMusica.buscarCategorias(musicaId);

  /// Associa categorias à música, criando as que ainda não existem.
  Future<void> atualizarCategorias(int musicaId, List<String> nomes) async {
    final ids = <int>[];
    for (final nome in nomes) {
      final trimado = nome.trim();
      if (trimado.isEmpty) continue;
      var categoria = await _daoCategoria.buscarPorNome(trimado);
      categoria ??= await _daoCategoria.buscarPorId(
        await _daoCategoria.salvar(ModeloCategoriaMusica(nome: trimado)),
      );
      if (categoria?.id != null) ids.add(categoria!.id!);
    }
    await _daoMusica.atualizarCategorias(musicaId, ids);
  }

  Future<List<ModeloVideoAula>> buscarVideos(int musicaId) =>
      _daoMusica.buscarVideos(musicaId);

  /// Cria (ou encontra) uma VideoAula pelo link e a associa à música.
  Future<String?> adicionarVideoAula(int musicaId, String link) async {
    final url = link.trim();
    if (url.isEmpty) return 'Link obrigatório.';
    var video = await _daoVideo.buscarPorLink(url);
    final videoId =
        video?.id ??
        await _daoVideo.salvar(ModeloVideoAula(nome: url, linkVideo: url));
    await _daoMusica.adicionarVideo(musicaId, videoId);
    return null;
  }

  /// Associa videoaulas à música, criando as que ainda não existem pelo link.
  Future<void> atualizarVideos(int musicaId, List<String> links) async {
    final ids = <int>[];
    for (final link in links) {
      final trimado = link.trim();
      if (trimado.isEmpty) continue;
      var video = await _daoVideo.buscarPorLink(trimado);
      video ??= await _daoVideo.buscarPorId(
        await _daoVideo.salvar(
          ModeloVideoAula(nome: trimado, linkVideo: trimado),
        ),
      );
      if (video?.id != null) ids.add(video!.id!);
    }
    await _daoMusica.atualizarVideos(musicaId, ids);
  }
}
