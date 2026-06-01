import 'package:spin_flow/model/dao/i_dao_aluno.dart';
import 'package:spin_flow/model/dao/i_dao_grupo_alunos.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_grupo_alunos.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';

class ServicoGrupoAlunos {
  final IDAOGrupoAlunos daoGrupoAlunos;
  final IDAOAluno daoAluno;

  const ServicoGrupoAlunos({
    required this.daoGrupoAlunos,
    required this.daoAluno,
  });

  Future<List<ModeloGrupoAlunos>> listar() => daoGrupoAlunos.buscarTodos();

  Future<List<ModeloAluno>> listarAlunos() => daoAluno.buscarAtivos();

  Future<String?> salvar(ModeloGrupoAlunos grupo) async {
    final erro = grupo.validar();
    if (erro != null) return erro;
    await daoGrupoAlunos.salvar(grupo);
    return null;
  }

  Future<void> excluir(int id) => daoGrupoAlunos.excluir(id);
}
