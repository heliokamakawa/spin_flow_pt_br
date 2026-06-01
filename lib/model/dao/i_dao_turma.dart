import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';

abstract class IDAOTurma {
  Future<List<ModeloTurma>> buscarTodos();
  Future<ModeloTurma?> buscarPorId(int id);
  Future<void> salvar(ModeloTurma turma);
  Future<void> excluir(int id);
}
