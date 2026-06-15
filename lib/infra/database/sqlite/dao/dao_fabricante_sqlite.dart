import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_fabricante.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';

class DAOFabricanteSQLite implements IDAOFabricante {
  static const _tabela = 'fabricante';

  @override
  Future<List<Fabricante>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapear).toList();
  }

  @override
  Future<Fabricante?> buscarPorNome(String nome) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery(
      'SELECT * FROM $_tabela WHERE LOWER(nome) = LOWER(?) LIMIT 1',
      [nome.trim()],
    );
    if (maps.isEmpty) return null;
    return _mapear(maps.first);
  }

  @override
  Future<void> salvar(Fabricante fabricante) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': fabricante.nome,
      'descricao': fabricante.descricao.isEmpty ? null : fabricante.descricao,
      'nome_contato_principal': fabricante.nomeContatoPrincipal.isEmpty
          ? null
          : fabricante.nomeContatoPrincipal,
      'email_contato':
          fabricante.emailContato.isEmpty ? null : fabricante.emailContato,
      'telefone_contato': fabricante.telefoneContato.isEmpty
          ? null
          : fabricante.telefoneContato,
      'ativo': fabricante.ativo ? 1 : 0,
    };
    if (fabricante.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [fabricante.id]);
    } else {
      await db.insert(_tabela, dados);
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Fabricante _mapear(Map<String, dynamic> map) => Fabricante(
        id: map['id'] as int?,
        nome: (map['nome'] as String?) ?? '',
        descricao: (map['descricao'] as String?) ?? '',
        nomeContatoPrincipal: (map['nome_contato_principal'] as String?) ?? '',
        emailContato: (map['email_contato'] as String?) ?? '',
        telefoneContato: (map['telefone_contato'] as String?) ?? '',
        ativo: ((map['ativo'] as int?) ?? 1) == 1,
      );
}
