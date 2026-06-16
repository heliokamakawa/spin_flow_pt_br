import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/domain/modelo/frequencia_aluno.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/turma.dart';
import 'package:spin_flow/domain/modelo/turma_aluno.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_operacao_aula.dart';

class ControladorOperacaoAula {
  final _repositorio = RepositorioOperacaoAula();

  Future<List<ResumoTurmaHoje>> listarTurmasHoje() => _repositorio.listarTurmasHoje();
  Future<EstadoMapaAula> carregarMapa(int turmaId) => _repositorio.carregarMapa(turmaId);
  Future<List<TipoManutencao>> listarTiposManutencao() => _repositorio.listarTiposManutencao();
  Future<List<Mix>> listarMixes() => _repositorio.listarMixes();

  Future<ResultadoOperacao> alterarMixTurma(int turmaId, int? mixId) async {
    try {
      await _repositorio.alterarMixTurma(turmaId, mixId);
      return const ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

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

  Future<List<FrequenciaAluno>> buscarFrequencia(
    int turmaId,
    DateTime inicio,
    DateTime fim,
  ) => _repositorio.buscarFrequencia(turmaId, inicio, fim);

  Future<List<FrequenciaAluno>> buscarAlunosPorProfessora(int professoraId) =>
      _repositorio.buscarAlunosPorProfessora(professoraId);

  Future<List<TurmaAluno>> buscarTurmasFrequentadasPorAluno(
    int alunoId,
    int professoraId,
  ) => _repositorio.buscarTurmasFrequentadasPorAluno(alunoId, professoraId);

  Future<Aluno?> buscarAlunoPorId(int id) =>
      _repositorio.buscarAlunoPorId(id);

  Future<List<Turma>> listarTurmasAtivas() => _repositorio.listarTurmasAtivas();

  Future<double?> calcularIdadeMediaTurma(int turmaId, DateTime data) =>
      _repositorio.calcularIdadeMediaTurma(turmaId, data);

  Future<List<String>> buscarNomesNaFila(int turmaId) =>
      _repositorio.buscarNomesNaFila(turmaId);
}
