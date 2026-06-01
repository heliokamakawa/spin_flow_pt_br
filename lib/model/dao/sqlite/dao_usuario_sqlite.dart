import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_usuario.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';

class DAOUsuarioSQLite implements IDAOUsuario {
  static const String _tabela = 'usuario';

  @override
  Future<ModeloUsuario?> autenticar({
    required String identificador,
    required String senha,
  }) async {
    final db = await ConexaoSQLite.database;
    final identificadorNormalizado = identificador.trim().toLowerCase();
    final cpfNormalizado = identificador.replaceAll(RegExp(r'\D'), '');
    final resultado = await db.query(
      _tabela,
      where: '(LOWER(email) = ? OR cpf = ?) AND senha = ? AND ativo = 1',
      whereArgs: [identificadorNormalizado, cpfNormalizado, senha],
      limit: 1,
    );

    if (resultado.isEmpty) return null;
    return _mapearUsuario(resultado.first);
  }

  @override
  Future<ModeloUsuario?> buscarPorEmail(String email) async {
    final db = await ConexaoSQLite.database;
    final resultado = await db.query(
      _tabela,
      where: 'LOWER(email) = ? AND ativo = 1',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return _mapearUsuario(resultado.first);
  }

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {
    final db = await ConexaoSQLite.database;
    await db.update(
      _tabela,
      {'senha': novaSenha},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  ModeloUsuario _mapearUsuario(Map<String, dynamic> map) {
    return ModeloUsuario(
      id: (map['id'] as int?) ?? 0,
      nome: (map['nome'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      cpf: (map['cpf'] as String?) ?? '',
      perfil: ((map['perfil'] as String?) ?? '').toLowerCase(),
      ativo: ((map['ativo'] as int?) ?? 0) == 1,
    );
  }
}
