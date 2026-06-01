import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_categoria_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_categoria_musica.dart';

class DAOCategoriaMusicaSQLite implements IDAOCategoriaMusica {
  static const _tabela = 'categoria_musica';

  @override
  Future<List<ModeloCategoriaMusica>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapParaModelo).toList();
  }

  @override
  Future<List<ModeloCategoriaMusica>> buscarAtivas() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'ativa = 1', orderBy: 'nome');
    return maps.map(_mapParaModelo).toList();
  }

  @override
  Future<ModeloCategoriaMusica?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : _mapParaModelo(maps.first);
  }

  @override
  Future<ModeloCategoriaMusica?> buscarPorNome(String nome) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'LOWER(nome) = LOWER(?)',
      whereArgs: [nome.trim()],
      limit: 1,
    );
    return maps.isEmpty ? null : _mapParaModelo(maps.first);
  }

  @override
  Future<int> salvar(ModeloCategoriaMusica categoria) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': categoria.nome,
      'descricao': categoria.descricao,
      'ativa': categoria.ativa ? 1 : 0,
    };
    if (categoria.id != null) {
      await db.update(
        _tabela,
        dados,
        where: 'id = ?',
        whereArgs: [categoria.id],
      );
      return categoria.id!;
    }
    return db.insert(_tabela, dados);
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativa': 0}, where: 'id = ?', whereArgs: [id]);
  }

  ModeloCategoriaMusica _mapParaModelo(Map<String, dynamic> map) {
    return ModeloCategoriaMusica(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      ativa: ((map['ativa'] as int?) ?? 1) == 1,
    );
  }
}
