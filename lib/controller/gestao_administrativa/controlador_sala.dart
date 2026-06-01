import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';
import 'package:spin_flow/model/servico/servico_sala.dart';

class ControladorSala {
  final ServicoSala servico;

  ControladorSala({required this.servico});

  Future<List<ModeloSala>> listar() => servico.listar();

  Future<ResultadoOperacao> salvar(ModeloSala sala) async {
    final erro = await servico.salvar(sala);
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => servico.excluir(id);
}
