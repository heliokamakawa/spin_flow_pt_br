import 'package:spin_flow/model/gestao_administrativa/modelo_grupo_alunos.dart';

abstract class IDAOGrupoAlunos {
  Future<List<ModeloGrupoAlunos>> buscarTodos();
  Future<ModeloGrupoAlunos?> buscarPorId(int id);
  Future<void> salvar(ModeloGrupoAlunos grupo);
  Future<void> excluir(int id);
}
