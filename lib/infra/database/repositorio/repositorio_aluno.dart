import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';

class RepositorioAluno {
  IDAOAluno get _dao => GetIt.I<IDAOAluno>();

  Future<void> salvar(Aluno aluno) => _dao.salvar(aluno);
  Future<Aluno?> buscarPorId(int id) => _dao.buscarPorId(id);
  Future<Aluno?> buscarPorEmail(String email) => _dao.buscarPorEmail(email);
  Future<Aluno?> buscarPorCpf(String cpf) => _dao.buscarPorCpf(cpf);
  Future<List<Aluno>> buscarTodos() => _dao.buscarTodos();
  Future<List<Aluno>> buscarAtivos() => _dao.buscarAtivos();
  Future<void> remover(int id) => _dao.excluir(id);
}
