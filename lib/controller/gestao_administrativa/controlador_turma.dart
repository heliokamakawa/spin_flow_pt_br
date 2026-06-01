import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/model/servico/servico_turma.dart';

class ControladorTurma {
  final ServicoTurma servico;

  const ControladorTurma({required this.servico});

  Future<List<ModeloTurma>> listar() => servico.listar();

  Future<List<ModeloSala>> listarSalas() => servico.listarSalas();

  Future<ResultadoOperacao> salvar(ModeloTurma turma) async {
    final erro = await servico.salvar(turma);
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => servico.excluir(id);
}
