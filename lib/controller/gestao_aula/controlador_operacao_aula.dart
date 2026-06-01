import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_tipo_manutencao.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';
import 'package:spin_flow/model/servico/servico_operacao_aula.dart';

class ControladorOperacaoAula {
  final ServicoOperacaoAula _servico;

  ControladorOperacaoAula({required ServicoOperacaoAula servico})
    : _servico = servico;

  Future<List<ResumoTurmaHoje>> listarTurmasHoje() =>
      _servico.listarTurmasHoje();

  Future<EstadoMapaAula> carregarMapa(int turmaId) =>
      _servico.carregarMapa(turmaId);

  Future<List<ModeloTipoManutencao>> listarTiposManutencao() =>
      _servico.listarTiposManutencao();

  Future<ResultadoOperacao> resolverManutencao(int bikeId) async {
    try {
      await _servico.resolverManutencao(bikeId);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> cancelarCheckin(int checkinId) async {
    try {
      await _servico.cancelarCheckin(checkinId);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> registrarManutencao({
    required int bikeId,
    required int tipoManutencaoId,
    required String descricao,
  }) async {
    try {
      await _servico.registrarManutencao(
        bikeId: bikeId,
        tipoManutencaoId: tipoManutencaoId,
        descricao: descricao.trim(),
      );
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }
}
