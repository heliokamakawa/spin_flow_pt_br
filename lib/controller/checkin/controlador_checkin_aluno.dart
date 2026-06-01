import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';
import 'package:spin_flow/model/gestao_aula/situacao_checkin_aluno.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';
import 'package:spin_flow/model/servico/servico_checkin_aluno.dart';

class ControladorCheckinAluno {
  final ServicoCheckinAluno _servico;

  ControladorCheckinAluno({required ServicoCheckinAluno servico})
    : _servico = servico;

  Future<ModeloAluno?> buscarAlunoPorEmail(String email) =>
      _servico.buscarAlunoPorEmail(email);

  Future<List<SituacaoCheckinAluno>> listarTurmasHoje(int alunoId) =>
      _servico.listarTurmasHoje(alunoId);

  Future<MapaCheckinAluno> carregarMapa(int turmaId, int alunoId) =>
      _servico.carregarMapa(turmaId, alunoId);

  Future<ResultadoOperacao> reservar({
    required int alunoId,
    required ModeloTurma turma,
    required DateTime data,
    required int fila,
    required int coluna,
  }) async {
    final erro = await _servico.reservar(
      alunoId: alunoId,
      turma: turma,
      data: data,
      fila: fila,
      coluna: coluna,
    );
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }

  Future<ResultadoOperacao> cancelarMinha(int checkinId) async {
    try {
      await _servico.cancelarMinha(checkinId);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> sairDaFila(int filaId) async {
    try {
      await _servico.sairDaFila(filaId);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> entrarFilaEspera(
    int alunoId,
    int turmaId,
    DateTime data,
  ) async {
    final erro = await _servico.entrarFilaEspera(alunoId, turmaId, data);
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }
}
