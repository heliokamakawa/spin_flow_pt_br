import 'package:spin_flow/domain/modelo/turma.dart';

abstract class IDAOTurma {
  Future<List<Turma>> buscarTodos();
  Future<Turma?> buscarPorId(int id);
  Future<void> salvar(Turma turma);
  Future<void> excluir(int id);
}
