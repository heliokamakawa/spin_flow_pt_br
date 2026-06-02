import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_artista_banda.dart';
import 'package:spin_flow/domain/modelo/artista_banda.dart';

class DAOArtistaBandaSQLite implements IDAOArtistaBanda {
  static const _tabela = 'artista_banda';

  @override
  Future<List<ArtistaBanda>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapParaModelo).toList();
  }

  @override
  Future<List<ArtistaBanda>> buscarAtivos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'ativo = 1', orderBy: 'nome');
    return maps.map(_mapParaModelo).toList();
  }

  @override
  Future<ArtistaBanda?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : _mapParaModelo(maps.first);
  }

  @override
  Future<int> salvar(ArtistaBanda artista) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': artista.nome,
      'descricao': artista.descricao,
      'link': artista.link,
      'foto': artista.foto,
      'ativo': artista.ativo ? 1 : 0,
    };
    if (artista.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [artista.id]);
      return artista.id!;
    }
    return db.insert(_tabela, dados);
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  ArtistaBanda _mapParaModelo(Map<String, dynamic> map) {
    return ArtistaBanda(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      link: (map['link'] as String?) ?? '',
      foto: (map['foto'] as String?) ?? '',
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }
}
