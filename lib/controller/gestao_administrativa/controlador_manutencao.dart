import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_bike.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_manutencao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_tipo_manutencao.dart';
import 'package:spin_flow/model/servico/servico_manutencao.dart';

class ControladorManutencao {
  final ServicoManutencao servico;

  ControladorManutencao({required this.servico});

  Future<List<ModeloManutencao>> listar() => servico.listar();
  Future<List<ModeloBike>> listarBikes() => servico.listarBikes();
  Future<List<ModeloTipoManutencao>> listarTipos() => servico.listarTipos();

  Future<ResultadoOperacao> salvar(ModeloManutencao manutencao) async {
    final erro = await servico.salvar(manutencao);
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => servico.excluir(id);
}
