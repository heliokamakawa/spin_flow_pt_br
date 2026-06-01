import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_grupo_alunos.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';
import 'package:spin_flow/model/servico/servico_grupo_alunos.dart';

class ControladorGrupoAlunos {
  final ServicoGrupoAlunos servico;

  const ControladorGrupoAlunos({required this.servico});

  Future<List<ModeloGrupoAlunos>> listar() => servico.listar();

  Future<List<ModeloAluno>> listarAlunos() => servico.listarAlunos();

  Future<ResultadoOperacao> salvar(ModeloGrupoAlunos grupo) async {
    final erro = await servico.salvar(grupo);
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => servico.excluir(id);
}
