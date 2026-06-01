import 'package:spin_flow/model/dao/i_dao_aluno.dart';
import 'package:spin_flow/model/dao/i_dao_checkin.dart';
import 'package:spin_flow/model/dao/i_dao_fila_espera_checkin.dart';
import 'package:spin_flow/model/dao/i_dao_manutencao.dart';
import 'package:spin_flow/model/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/model/dao/i_dao_sala.dart';
import 'package:spin_flow/model/dao/i_dao_turma.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';
import 'package:spin_flow/model/gestao_aula/modelo_checkin.dart';
import 'package:spin_flow/model/gestao_aula/modelo_posicao_bike.dart';
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

  Future<List<ResumoTurmaCheckin>> listarTurmasHoje(int alunoId) async {
    final hoje = _diaSemanaHoje();
    final salas = await _daoSala.buscarTodos();
    final salasPorId = {for (final s in salas) s.id: s};
    final todasPosicoes = await _daoPosicaoBike.buscarTodos();
    final bikesManutencao = await _daoManutencao
        .buscarBikeIdsEmManutencaoAtiva();

    final turmas = await _daoTurma.buscarTodos();
    final turmasHoje =
        turmas.where((t) => t.ativo && t.diasSemana.contains(hoje)).toList()
          ..sort((a, b) => a.horarioInicio.compareTo(b.horarioInicio));

    final agora = DateTime.now();
    final dataHoje = DateTime(agora.year, agora.month, agora.day);
    final resultado = <ResumoTurmaCheckin>[];

    for (final turma in turmasHoje) {
      final sala = salasPorId[turma.salaId];
      if (sala == null) continue;

      final totalBikes = _contarBikes(sala, todasPosicoes, bikesManutencao);
      final checkins = await _daoCheckin.buscarAtivosPorTurmaData(
        turma.id!,
        dataHoje,
      );
      final vagas = (totalBikes - checkins.length).clamp(0, totalBikes);
      final alunoJaTem = checkins.any((c) => c.alunoId == alunoId);
      final posicaoFila = await _daoFila.buscarPosicaoNaFila(
        alunoId,
        turma.id!,
        dataHoje,
      );

      resultado.add(
        ResumoTurmaCheckin(
          turma: turma,
          nomeSala: sala.nome,
          totalBikes: totalBikes,
          vagasDisponiveis: vagas,
          janelAberta: _janelAberta(turma, agora),
          alunoJaTemCheckin: alunoJaTem,
          posicaoNaFila: posicaoFila,
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
      janelAberta: _janelAberta(turma, agora),
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
    if (!_janelAberta(turma, agora)) {
      return 'Reserva disponível 30 min antes da aula.';
    }
    final aluno = await _daoAluno.buscarPorId(alunoId);
    if (aluno == null || !aluno.ativo) return 'Aluno inativo.';
    if (await _daoCheckin.existeAtivoPorAluno(alunoId, turma.id!, data)) {
      return 'Você já tem reserva nesta turma.';
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

  // ── Helpers privados ──────────────────────────────────────────────────────

  int _contarBikes(
    ModeloSala sala,
    List<ModeloPosicaoBike> posicoes,
    Set<int> emManutencao,
  ) {
    return posicoes.where((p) {
      if (p.fila >= sala.numeroFilas || p.coluna >= sala.numeroColunas)
        return false;
      if (p.fila == sala.filaProfessora - 1 &&
          p.coluna == sala.colunaProfessora - 1)
        return false;
      if (p.bikeId != null && emManutencao.contains(p.bikeId)) return false;
      return true;
    }).length;
  }

  bool _janelAberta(ModeloTurma turma, DateTime agora) {
    final partes = turma.horarioInicio.split(':');
    if (partes.length < 2) return false;
    final h = int.tryParse(partes[0]) ?? 0;
    final m = int.tryParse(partes[1]) ?? 0;
    final inicio = DateTime(agora.year, agora.month, agora.day, h, m);
    final abertura = inicio.subtract(const Duration(minutes: 30));
    return !agora.isBefore(abertura);
  }

  DiaSemana _diaSemanaHoje() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return DiaSemana.segunda;
      case DateTime.tuesday:
        return DiaSemana.terca;
      case DateTime.wednesday:
        return DiaSemana.quarta;
      case DateTime.thursday:
        return DiaSemana.quinta;
      case DateTime.friday:
        return DiaSemana.sexta;
      case DateTime.saturday:
        return DiaSemana.sabado;
      default:
        return DiaSemana.domingo;
    }
  }
}
