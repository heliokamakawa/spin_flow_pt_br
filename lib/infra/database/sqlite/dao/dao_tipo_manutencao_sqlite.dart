import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';

class DAOTipoManutencaoSQLite implements IDAOTipoManutencao {
  static const _tabela = 'tipo_manutencao';

  @override
  Future<List<TipoManutencao>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapear).toList();
  }

  @override
  Future<void> salvar(TipoManutencao tipo) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': tipo.nome,
      'descricao': tipo.descricao.isEmpty ? null : tipo.descricao,
      'ativa': tipo.ativa ? 1 : 0,
    };
    if (tipo.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [tipo.id]);
    } else {
      await db.insert(_tabela, dados);
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativa': 0}, where: 'id = ?', whereArgs: [id]);
  }

  TipoManutencao _mapear(Map<String, dynamic> map) =>
      TipoManutencao(
        id: map['id'] as int?,
        nome: (map['nome'] as String?) ?? '',
        descricao: (map['descricao'] as String?) ?? '',
        ativa: ((map['ativa'] as int?) ?? 1) == 1,
      );
}
