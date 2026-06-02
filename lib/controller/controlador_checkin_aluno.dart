import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/domain/dominio/dominio_checkin.dart';
import 'package:spin_flow/domain/modelo/checkin.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/painel_aluno.dart';
import 'package:spin_flow/domain/modelo/turma.dart';
import 'package:spin_flow/domain/modelo/situacao_checkin_aluno.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_checkin_aluno.dart';

class ControladorCheckinAluno {
  final _repositorio = RepositorioCheckinAluno();

  Future<Aluno?> buscarAlunoPorEmail(String email) =>
      _repositorio.buscarAlunoPorEmail(email);

  Future<List<SituacaoCheckinAluno>> listarTurmasHoje(int alunoId) =>
      _repositorio.listarTurmasHoje(alunoId);

  Future<MapaCheckinAluno> carregarMapa(int turmaId, int alunoId) =>
      _repositorio.carregarMapa(turmaId, alunoId);

  Future<ResultadoOperacao> reservar({
    required int alunoId,
    required Turma turma,
    required DateTime data,
    required int fila,
    required int coluna,
  }) async {
    final dominio = DominioCheckin(Checkin(
      alunoId: alunoId,
      turmaId: turma.id!,
      data: data,
      fila: fila,
      coluna: coluna,
    ));
    final erroValidacao = dominio.validarParaSalvar();
    if (erroValidacao != null) return ResultadoOperacao.falha(mensagemErro: erroValidacao);
    final erro = await _repositorio.reservar(
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
      await _repositorio.cancelarMinha(checkinId);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> sairDaFila(int filaId) async {
    try {
      await _repositorio.sairDaFila(filaId);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> avaliarMusica(int alunoId, int musicaId, int nota) async {
    try {
      await _repositorio.avaliarMusica(alunoId, musicaId, nota);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> entrarFilaEspera(int alunoId, int turmaId, DateTime data) async {
    final erro = await _repositorio.entrarFilaEspera(alunoId, turmaId, data);
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }

  Future<PainelAluno?> buscarPainelAluno(int alunoId) =>
      _repositorio.buscarPainelAluno(alunoId);

  Future<MixCheckin?> buscarMixComAvaliacoes(int mixId, int alunoId) =>
      _repositorio.buscarMixComAvaliacoes(mixId, alunoId);
}
