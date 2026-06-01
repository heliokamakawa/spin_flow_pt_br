import 'package:spin_flow/model/dao/i_dao_aluno.dart';
import 'package:spin_flow/model/dao/i_dao_checkin.dart';
import 'package:spin_flow/model/dao/i_dao_fila_espera_checkin.dart';
import 'package:spin_flow/model/dao/i_dao_manutencao.dart';
import 'package:spin_flow/model/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/model/dao/i_dao_sala.dart';
import 'package:spin_flow/model/dao/i_dao_turma.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';
import 'package:spin_flow/model/gestao_aula/modelo_checkin.dart';
import 'package:spin_flow/model/gestao_aula/situacao_checkin_aluno.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';

class ServicoCheckinAluno {
  final IDAOTurma _daoTurma;
  final IDAOSala _daoSala;
  final IDAOAluno _daoAluno;
  final IDAOCheckin _daoCheckin;
  final IDAOPosicaoBike _daoPosicaoBike;
  final IDAOManutencao _daoManutencao;
  final IDAOFilaEsperaCheckin _daoFila;

  ServicoCheckinAluno({
    required IDAOTurma daoTurma,
    required IDAOSala daoSala,
    required IDAOAluno daoAluno,
    required IDAOCheckin daoCheckin,
    required IDAOPosicaoBike daoPosicaoBike,
    required IDAOManutencao daoManutencao,
    required IDAOFilaEsperaCheckin daoFila,
  }) : _daoTurma = daoTurma,
       _daoSala = daoSala,
       _daoAluno = daoAluno,
       _daoCheckin = daoCheckin,
       _daoPosicaoBike = daoPosicaoBike,
       _daoManutencao = daoManutencao,
       _daoFila = daoFila;

  // ── Aluno logado ───────────────────────────────────────────────────────────

  Future<ModeloAluno?> buscarAlunoPorEmail(String email) =>
      _daoAluno.buscarPorEmail(email);

  // ── Lista de turmas do dia ─────────────────────────────────────────────────

  Future<List<SituacaoCheckinAluno>> listarTurmasHoje(int alunoId) async {
    final agora = DateTime.now();
    final dataHoje = DateTime(agora.year, agora.month, agora.day);

    final salas = await _daoSala.buscarTodos();
    final salasPorId = {for (final s in salas) s.id: s};
    final todasPosicoes = await _daoPosicaoBike.buscarTodos();
    final bikesManutencao = await _daoManutencao.buscarBikeIdsEmManutencaoAtiva();

    final turmas = await _daoTurma.buscarTodos();
    final turmasHoje = turmas
        .where((t) => t.ativo && t.ocorreEm(DiaSemana.hoje()))
        .toList()
      ..sort((a, b) => a.horarioInicio.compareTo(b.horarioInicio));

    // check-ins ativos do aluno hoje (todas as turmas)
    final checkinsAluno = await _daoCheckin.buscarAtivosPorAlunoDia(
      alunoId,
      dataHoje,
    );
    final turmasPorId = {for (final t in turmas) t.id: t};

    final resultado = <SituacaoCheckinAluno>[];

    for (final turma in turmasHoje) {
      final sala = salasPorId[turma.salaId];
      if (sala == null) continue;

      final totalBikes = sala.bikesDisponiveis(todasPosicoes, bikesManutencao);
      final checkinsNaTurma = await _daoCheckin.buscarAtivosPorTurmaData(
        turma.id!,
        dataHoje,
      );
      final vagas = (totalBikes - checkinsNaTurma.length).clamp(0, totalBikes);

      StatusCheckinAluno status;
      String? nomeTurmaConflito;
      int? posicaoNaFila;

      if (checkinsNaTurma.any((c) => c.alunoId == alunoId)) {
        status = StatusCheckinAluno.confirmado;
      } else {
        posicaoNaFila = await _daoFila.buscarPosicaoNaFila(
          alunoId, turma.id!, dataHoje,
        );
        if (posicaoNaFila != null) {
          status = StatusCheckinAluno.emFila;
        } else {
          ModeloCheckin? conflito;
          for (final c in checkinsAluno) {
            if (c.turmaId == turma.id) continue;
            final outra = turmasPorId[c.turmaId];
            if (outra != null && turma.sobrepoeHorario(outra, dataHoje)) {
              conflito = c;
              break;
            }
          }
          if (conflito != null) {
            status = StatusCheckinAluno.conflito;
            nomeTurmaConflito = turmasPorId[conflito.turmaId]?.nome;
          } else if (!turma.janelAberta(agora)) {
            status = StatusCheckinAluno.janelaFechada;
          } else if (vagas == 0) {
            status = StatusCheckinAluno.lotada;
          } else {
            status = StatusCheckinAluno.disponivel;
          }
        }
      }

      resultado.add(
        SituacaoCheckinAluno(
          turma: turma,
          nomeSala: sala.nome,
          totalBikes: totalBikes,
          vagasDisponiveis: vagas,
          status: status,
          posicaoNaFila: posicaoNaFila,
          nomeTurmaConflito: nomeTurmaConflito,
        ),
      );
    }
    return resultado;
  }

  // ── Mapa da turma (visao do aluno) ────────────────────────────────────────

  Future<MapaCheckinAluno> carregarMapa(int turmaId, int alunoId) async {
    final turma = await _daoTurma.buscarPorId(turmaId);
    if (turma == null) throw Exception('Turma não encontrada.');
    final sala = await _daoSala.buscarPorId(turma.salaId);
    if (sala == null) throw Exception('Sala não encontrada.');

    final agora = DateTime.now();
    final dataHoje = DateTime(agora.year, agora.month, agora.day);

    final posicoes = await _daoPosicaoBike.buscarTodos();
    final checkins = await _daoCheckin.buscarAtivosPorTurmaData(
      turmaId,
      dataHoje,
    );
    final bikesManutencao = await _daoManutencao
        .buscarBikeIdsEmManutencaoAtiva();

    final mapa = EstadoMapaAula(
      turma: turma,
      sala: sala,
      posicoes: posicoes,
      checkinsAtivos: checkins,
      bikeIdsEmManutencao: bikesManutencao,
    );

    final meuCheckin = checkins.where((c) => c.alunoId == alunoId).firstOrNull;
    final posicaoFila = await _daoFila.buscarPosicaoNaFila(
      alunoId,
      turmaId,
      dataHoje,
    );
    final filaId = await _daoFila.buscarIdDoAluno(alunoId, turmaId, dataHoje);

    return MapaCheckinAluno(
      mapa: mapa,
      alunoId: alunoId,
      janelAberta: turma.janelAberta(agora),
      idCheckinDoAluno: meuCheckin?.id,
      posicaoNaFila: posicaoFila,
      filaId: filaId,
    );
  }

  // ── Reservar bike ──────────────────────────────────────────────────────────

  Future<String?> reservar({
    required int alunoId,
    required ModeloTurma turma,
    required DateTime data,
    required int fila,
    required int coluna,
  }) async {
    final agora = DateTime.now();
    if (!turma.janelAberta(agora)) {
      return 'Reserva disponível 30 min antes da aula.';
    }
    final aluno = await _daoAluno.buscarPorId(alunoId);
    if (aluno == null || !aluno.ativo) return 'Aluno inativo.';
    if (await _daoCheckin.existeAtivoPorAluno(alunoId, turma.id!, data)) {
      return 'Você já tem reserva nesta turma.';
    }
    final checkinsHoje = await _daoCheckin.buscarAtivosPorAlunoDia(alunoId, data);
    final todasTurmas = await _daoTurma.buscarTodos();
    final turmasPorId = {for (final t in todasTurmas) t.id: t};
    for (final c in checkinsHoje) {
      if (c.turmaId == turma.id) continue;
      final outra = turmasPorId[c.turmaId];
      if (outra != null && turma.sobrepoeHorario(outra, data)) {
        return 'Você já tem check-in em ${outra.nome} neste horário.';
      }
    }
    if (await _daoCheckin.existeAtivoPorPosicao(
      turma.id!,
      data,
      fila,
      coluna,
    )) {
      return 'Posição já ocupada.';
    }
    await _daoCheckin.salvar(
      ModeloCheckin(
        alunoId: alunoId,
        turmaId: turma.id!,
        data: data,
        fila: fila,
        coluna: coluna,
      ),
    );
    return null;
  }

  // ── Cancelar propria reserva ──────────────────────────────────────────────

  Future<void> cancelarMinha(int checkinId) => _daoCheckin.cancelar(checkinId);

  // ── Fila de espera ────────────────────────────────────────────────────────

  Future<String?> entrarFilaEspera(
    int alunoId,
    int turmaId,
    DateTime data,
  ) async {
    if (await _daoCheckin.existeAtivoPorAluno(alunoId, turmaId, data)) {
      return 'Você já tem reserva nesta turma.';
    }
    try {
      await _daoFila.entrarNaFila(alunoId, turmaId, data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> sairDaFila(int filaId) => _daoFila.sairDaFila(filaId);

}
