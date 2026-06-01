import 'package:spin_flow/model/dao/i_dao_aluno.dart';
import 'package:spin_flow/model/dao/sqlite/dao_aluno_sqlite.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';

class ServicoAluno {
  final IDAOAluno _daoAluno;

  ServicoAluno({IDAOAluno? daoAluno})
    : _daoAluno = daoAluno ?? DAOAlunoSQLite();

  Future<void> salvar(ModeloAluno aluno) async {
    await _daoAluno.salvar(aluno);
  }

  Future<ModeloAluno?> buscarPorId(int id) {
    return _daoAluno.buscarPorId(id);
  }

  Future<List<ModeloAluno>> buscarTodos() {
    return _daoAluno.buscarTodos();
  }

  Future<void> atualizar(ModeloAluno aluno) async {
    await _daoAluno.salvar(aluno);
  }

  Future<void> remover(int id) async {
    await _daoAluno.excluir(id);
  }
}
