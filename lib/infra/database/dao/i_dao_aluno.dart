import 'package:spin_flow/domain/modelo/aluno.dart';

abstract class IDAOAluno {
  Future<List<Aluno>> buscarTodos();
  Future<List<Aluno>> buscarAtivos();
  Future<Aluno?> buscarPorId(int id);
  Future<Aluno?> buscarPorEmail(String email);
  Future<void> salvar(Aluno aluno);
  Future<void> excluir(int id);
}
