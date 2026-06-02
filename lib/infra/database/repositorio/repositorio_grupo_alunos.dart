import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/infra/database/dao/i_dao_grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/grupo_alunos.dart';

class RepositorioGrupoAlunos {
  IDAOGrupoAlunos get _daoGrupo => GetIt.I<IDAOGrupoAlunos>();
  IDAOAluno       get _daoAluno => GetIt.I<IDAOAluno>();

  Future<List<GrupoAlunos>> listar() => _daoGrupo.buscarTodos();
  Future<List<Aluno>> listarAlunos() => _daoAluno.buscarAtivos();

  Future<void> salvar(GrupoAlunos grupo) => _daoGrupo.salvar(grupo);

  Future<void> excluir(int id) => _daoGrupo.excluir(id);
}
