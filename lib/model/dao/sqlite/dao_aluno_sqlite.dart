import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_aluno.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';

class DAOAlunoSQLite implements IDAOAluno {
  static const String _tabela = 'aluno';

  @override
  Future<List<ModeloAluno>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'nome');
    return maps.map(_mapear).toList();
  }

  @override
  Future<List<ModeloAluno>> buscarAtivos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'ativo = 1', orderBy: 'nome');
    return maps.map(_mapear).toList();
  }

  @override
  Future<ModeloAluno?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _mapear(maps.first);
  }

  @override
  Future<ModeloAluno?> buscarPorEmail(String email) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'LOWER(email) = LOWER(?) AND ativo = 1',
      whereArgs: [email.trim()],
      limit: 1,
    );
    return maps.isEmpty ? null : _mapear(maps.first);
  }

  @override
  Future<void> salvar(ModeloAluno aluno) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': aluno.nome,
      'email': aluno.email,
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
    } else {
      await db.insert(_tabela, dados);
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  ModeloAluno _mapear(Map<String, dynamic> map) {
    return ModeloAluno(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
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
