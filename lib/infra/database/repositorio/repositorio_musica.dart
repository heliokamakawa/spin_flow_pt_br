import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_categoria_musica.dart';
import 'package:spin_flow/infra/database/dao/i_dao_musica.dart';
import 'package:spin_flow/infra/database/dao/i_dao_video_aula.dart';
import 'package:spin_flow/domain/modelo/categoria_musica.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/domain/modelo/video_aula.dart';

class RepositorioMusica {
  IDAOMusica         get _daoMusica   => GetIt.I<IDAOMusica>();
  IDAOCategoriaMusica get _daoCategoria => GetIt.I<IDAOCategoriaMusica>();
  IDAOVideoAula      get _daoVideo    => GetIt.I<IDAOVideoAula>();

  Future<List<Musica>> listarAtivas() => _daoMusica.buscarAtivas();

  Future<List<CategoriaMusica>> listarCategorias() =>
      _daoCategoria.buscarAtivas();

  Future<void> salvar(Musica musica) => _daoMusica.salvar(musica);

  Future<void> salvarComCategorias(
    Musica musica,
    List<String> nomesCategoria,
  ) async {
    final id = await _daoMusica.salvar(musica);
    await atualizarCategorias(id, nomesCategoria);
  }

  Future<void> excluir(int id) => _daoMusica.excluir(id);

  Future<List<CategoriaMusica>> buscarCategorias(int musicaId) =>
      _daoMusica.buscarCategorias(musicaId);

  Future<void> atualizarCategorias(int musicaId, List<String> nomes) async {
    final ids = <int>[];
    for (final nome in nomes) {
      final trimado = nome.trim();
      if (trimado.isEmpty) continue;
      var categoria = await _daoCategoria.buscarPorNome(trimado);
      categoria ??= await _daoCategoria.buscarPorId(
        await _daoCategoria.salvar(CategoriaMusica(nome: trimado)),
      );
      if (categoria?.id != null) ids.add(categoria!.id!);
    }
    await _daoMusica.atualizarCategorias(musicaId, ids);
  }

  Future<List<VideoAula>> buscarVideos(int musicaId) =>
      _daoMusica.buscarVideos(musicaId);

  Future<void> adicionarVideoAula(int musicaId, String url) async {
    var video = await _daoVideo.buscarPorLink(url);
    final videoId =
        video?.id ?? await _daoVideo.salvar(VideoAula(nome: url, linkVideo: url));
    await _daoMusica.adicionarVideo(musicaId, videoId);
  }

  Future<void> atualizarVideos(int musicaId, List<String> links) async {
    final ids = <int>[];
    for (final link in links) {
      final trimado = link.trim();
      if (trimado.isEmpty) continue;
      var video = await _daoVideo.buscarPorLink(trimado);
      video ??= await _daoVideo.buscarPorId(
        await _daoVideo.salvar(
          VideoAula(nome: trimado, linkVideo: trimado),
        ),
      );
      if (video?.id != null) ids.add(video!.id!);
    }
    await _daoMusica.atualizarVideos(musicaId, ids);
  }
}
