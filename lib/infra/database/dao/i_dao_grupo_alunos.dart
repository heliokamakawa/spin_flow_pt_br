import 'package:spin_flow/domain/modelo/grupo_alunos.dart';

abstract class IDAOGrupoAlunos {
  Future<List<GrupoAlunos>> buscarTodos();
  Future<GrupoAlunos?> buscarPorId(int id);
  Future<void> salvar(GrupoAlunos grupo);
  Future<void> excluir(int id);
}
