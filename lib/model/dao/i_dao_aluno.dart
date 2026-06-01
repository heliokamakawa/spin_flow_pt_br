import 'package:spin_flow/model/modelo/modelo_aluno.dart';

abstract class IDAOAluno {
  Future<List<ModeloAluno>> buscarTodos();
  Future<List<ModeloAluno>> buscarAtivos();
  Future<ModeloAluno?> buscarPorId(int id);
  Future<ModeloAluno?> buscarPorEmail(String email);
  Future<void> salvar(ModeloAluno aluno);
  Future<void> excluir(int id);
}
