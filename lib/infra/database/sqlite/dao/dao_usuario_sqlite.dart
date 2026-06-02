import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

class DAOUsuarioSQLite implements IDAOUsuario {
  static const String _tabela = 'usuario';

  @override
  Future<Usuario?> buscarPorCredencial({
    required String identificador,
    required String senha,
  }) async {
    final db = await ConexaoSQLite.database;
    final resultado = await db.rawQuery(
      '''
      SELECT id, nome, email, cpf, aluno_id, professora_id, ativo
      FROM $_tabela
      WHERE (LOWER(email) = ? OR cpf = ?)
        AND senha = ?
      LIMIT 1
      ''',
      [
        identificador.trim().toLowerCase(),
        identificador.replaceAll(RegExp(r'\D'), ''),
        senha,
      ],
    );
    if (resultado.isEmpty) return null;
    return _mapearUsuario(resultado.first);
  }

  @override
  Future<Usuario?> buscarPorEmail(String email) async {
    final db = await ConexaoSQLite.database;
    final resultado = await db.rawQuery(
      '''
      SELECT id, nome, email, cpf, aluno_id, professora_id, ativo
      FROM $_tabela
      WHERE LOWER(email) = ?
      LIMIT 1
      ''',
      [email.trim().toLowerCase()],
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

  @override
  Future<Map<int, String>> buscarNomesProfessoras() async {
    final db = await ConexaoSQLite.database;
    final rows = await db.rawQuery(
      'SELECT professora_id, nome FROM usuario WHERE professora_id IS NOT NULL AND ativo = 1',
    );
    return {
      for (final row in rows)
        (row['professora_id'] as int): (row['nome'] as String),
    };
  }

  Usuario _mapearUsuario(Map<String, dynamic> map) {
    return Usuario(
      id: (map['id'] as int?) ?? 0,
      nome: (map['nome'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      cpf: (map['cpf'] as String?) ?? '',
      alunoId: map['aluno_id'] as int?,
      professoraId: map['professora_id'] as int?,
      ativo: ((map['ativo'] as int?) ?? 0) == 1,
    );
  }
}
