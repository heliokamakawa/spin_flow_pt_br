import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_operacao_aula.dart';

class ControladorOperacaoAula {
  final _repositorio = RepositorioOperacaoAula();

  Future<List<ResumoTurmaHoje>> listarTurmasHoje() => _repositorio.listarTurmasHoje();
  Future<EstadoMapaAula> carregarMapa(int turmaId) => _repositorio.carregarMapa(turmaId);
  Future<List<TipoManutencao>> listarTiposManutencao() => _repositorio.listarTiposManutencao();

  Future<ResultadoOperacao> resolverManutencao(int bikeId) async {
    try {
      await _repositorio.resolverManutencao(bikeId);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> cancelarCheckin(int checkinId) async {
    try {
      await _repositorio.cancelarCheckin(checkinId);
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
      await _repositorio.registrarManutencao(
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
