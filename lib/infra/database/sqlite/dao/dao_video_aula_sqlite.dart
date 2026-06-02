import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_video_aula.dart';
import 'package:spin_flow/domain/modelo/video_aula.dart';

class DAOVideoAulaSQLite implements IDAOVideoAula {
  static const _tabela = 'video_aula';

  @override
  Future<List<VideoAula>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'ativo = 1', orderBy: 'nome');
    return maps.map(_mapParaModelo).toList();
  }

  @override
  Future<VideoAula?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : _mapParaModelo(maps.first);
  }

  @override
  Future<VideoAula?> buscarPorLink(String linkVideo) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'link_video = ?',
      whereArgs: [linkVideo.trim()],
      limit: 1,
    );
    return maps.isEmpty ? null : _mapParaModelo(maps.first);
  }

  @override
  Future<int> salvar(VideoAula video) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': video.nome,
      'link_video': video.linkVideo,
      'ativo': video.ativo ? 1 : 0,
    };
    if (video.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [video.id]);
      return video.id!;
    }
    return db.insert(_tabela, dados);
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  VideoAula _mapParaModelo(Map<String, dynamic> map) {
    return VideoAula(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      linkVideo: (map['link_video'] as String?) ?? '',
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }
}
