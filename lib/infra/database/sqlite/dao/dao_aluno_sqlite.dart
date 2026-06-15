import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';

class DAOAlunoSQLite implements IDAOAluno {
  static const String _tabela = 'aluno';

  @override
  Future<List<Aluno>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT a.*, u.nome AS u_nome, u.email AS u_email, u.cpf AS u_cpf
      FROM aluno a
      LEFT JOIN usuario u ON u.aluno_id = a.id
      ORDER BY u.nome
    ''');
    return maps.map(_mapear).toList();
  }

  @override
  Future<List<Aluno>> buscarAtivos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT a.*, u.nome AS u_nome, u.email AS u_email, u.cpf AS u_cpf
      FROM aluno a
      LEFT JOIN usuario u ON u.aluno_id = a.id
      WHERE a.ativo = 1
      ORDER BY u.nome
    ''');
    return maps.map(_mapear).toList();
  }

  @override
  Future<Aluno?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT a.*, u.nome AS u_nome, u.email AS u_email, u.cpf AS u_cpf
      FROM aluno a
      LEFT JOIN usuario u ON u.aluno_id = a.id
      WHERE a.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    return _mapear(maps.first);
  }

  @override
  Future<Aluno?> buscarPorEmail(String email) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT a.*, u.nome AS u_nome, u.email AS u_email, u.cpf AS u_cpf
      FROM aluno a
      JOIN usuario u ON u.aluno_id = a.id
      WHERE LOWER(u.email) = LOWER(?) AND a.ativo = 1
      LIMIT 1
    ''', [email.trim()]);
    return maps.isEmpty ? null : _mapear(maps.first);
  }

  @override
  Future<Aluno?> buscarPorCpf(String cpf) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.rawQuery('''
      SELECT a.*, u.nome AS u_nome, u.email AS u_email, u.cpf AS u_cpf
      FROM aluno a
      JOIN usuario u ON u.aluno_id = a.id
      WHERE u.cpf = ?
      LIMIT 1
    ''', [cpf.replaceAll(RegExp(r'\D'), '')]);
    return maps.isEmpty ? null : _mapear(maps.first);
  }

  @override
  Future<void> salvar(Aluno aluno) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'data_nascimento': aluno.dataNascimento?.toIso8601String(),
      'genero': aluno.genero,
      'telefone': aluno.telefone,
      'url_foto': aluno.urlFoto,
      'instagram': aluno.instagram,
      'facebook': aluno.facebook,
      'tiktok': aluno.tiktok,
      'observacoes': aluno.observacoes,
      'ativo': aluno.ativo ? 1 : 0,
    };

    if (aluno.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [aluno.id]);
      await db.execute(
        'UPDATE usuario SET nome = ?, email = ?, cpf = ? WHERE aluno_id = ?',
        [aluno.nome, aluno.email, aluno.cpf, aluno.id],
      );
    } else {
      await db.transaction((txn) async {
        final novoId = await txn.insert(_tabela, dados);
        await txn.insert('usuario', {
          'nome': aluno.nome,
          'email': aluno.email,
          'cpf': aluno.cpf,
          'senha': aluno.cpf, // senha inicial = CPF; aluno faz login com e-mail + CPF
          'aluno_id': novoId,
          'ativo': 1,
        });
      });
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Aluno _mapear(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as int?,
      nome: (map['u_nome'] as String?) ?? '',
      cpf: (map['u_cpf'] as String?) ?? '',
      email: (map['u_email'] as String?) ?? '',
      dataNascimento: DateTime.tryParse(
        (map['data_nascimento'] as String?) ?? '',
      ),
      genero: (map['genero'] as String?) ?? '',
      telefone: (map['telefone'] as String?) ?? '',
      urlFoto: (map['url_foto'] as String?) ?? '',
      instagram: (map['instagram'] as String?) ?? '',
      facebook: (map['facebook'] as String?) ?? '',
      tiktok: (map['tiktok'] as String?) ?? '',
      observacoes: (map['observacoes'] as String?) ?? '',
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }
}
