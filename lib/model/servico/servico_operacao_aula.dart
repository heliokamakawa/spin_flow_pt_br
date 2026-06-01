import 'package:spin_flow/model/dao/i_dao_checkin.dart';
import 'package:spin_flow/model/dao/i_dao_manutencao.dart';
import 'package:spin_flow/model/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/model/dao/i_dao_sala.dart';
import 'package:spin_flow/model/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/model/dao/i_dao_turma.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_manutencao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_tipo_manutencao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';

class ServicoOperacaoAula {
  final IDAOTurma _daoTurma;
  final IDAOSala _daoSala;
  final IDAOPosicaoBike _daoPosicaoBike;
  final IDAOCheckin _daoCheckin;
  final IDAOManutencao _daoManutencao;
  final IDAOTipoManutencao _daoTipoManutencao;

  ServicoOperacaoAula({
    required IDAOTurma daoTurma,
    required IDAOSala daoSala,
    required IDAOPosicaoBike daoPosicaoBike,
    required IDAOCheckin daoCheckin,
    required IDAOManutencao daoManutencao,
    required IDAOTipoManutencao daoTipoManutencao,
  }) : _daoTurma = daoTurma,
       _daoSala = daoSala,
       _daoPosicaoBike = daoPosicaoBike,
       _daoCheckin = daoCheckin,
       _daoManutencao = daoManutencao,
       _daoTipoManutencao = daoTipoManutencao;

  Future<List<ResumoTurmaHoje>> listarTurmasHoje() async {
    final hoje = _diaSemanaHoje();
    final salas = await _daoSala.buscarTodos();
    final salasPorId = {for (final s in salas) s.id: s.nome};

    final turmas = await _daoTurma.buscarTodos();
    final turmasHoje =
        turmas.where((t) => t.ativo && t.diasSemana.contains(hoje)).toList()
          ..sort((a, b) => a.horarioInicio.compareTo(b.horarioInicio));

    return turmasHoje
        .map(
          (t) =>
              ResumoTurmaHoje(turma: t, nomeSala: salasPorId[t.salaId] ?? '—'),
        )
        .toList();
  }

  Future<EstadoMapaAula> carregarMapa(int turmaId) async {
    final turma = await _daoTurma.buscarPorId(turmaId);
    if (turma == null) throw Exception('Turma não encontrada.');
    final sala = await _daoSala.buscarPorId(turma.salaId);
    if (sala == null) throw Exception('Sala não encontrada.');

    final hoje = DateTime.now();
    final data = DateTime(hoje.year, hoje.month, hoje.day);

    final posicoes = await _daoPosicaoBike.buscarTodos();
    final checkins = await _daoCheckin.buscarAtivosPorTurmaData(turmaId, data);
    final bikesManutencao = await _daoManutencao
        .buscarBikeIdsEmManutencaoAtiva();

    return EstadoMapaAula(
      turma: turma,
      sala: sala,
      posicoes: posicoes,
      checkinsAtivos: checkins,
      bikeIdsEmManutencao: bikesManutencao,
    );
  }

  Future<List<ModeloTipoManutencao>> listarTiposManutencao() =>
      _daoTipoManutencao.buscarTodos();

  Future<void> cancelarCheckin(int checkinId) =>
      _daoCheckin.cancelar(checkinId);

  Future<void> resolverManutencao(int bikeId) async {
    final m = await _daoManutencao.buscarManutencaoAtivaPorBikeId(bikeId);
    if (m?.id == null) return;
    await _daoManutencao.salvar(
      ModeloManutencao(
        id: m!.id,
        bikeId: m.bikeId,
        tipoManutencaoId: m.tipoManutencaoId,
        dataSolicitacao: m.dataSolicitacao,
        descricao: m.descricao,
        estadoOperacional: EstadoOperacional.realizado,
      ),
    );
  }

  Future<void> registrarManutencao({
    required int bikeId,
    required int tipoManutencaoId,
    required String descricao,
  }) async {
    final m = ModeloManutencao(
      bikeId: bikeId,
      tipoManutencaoId: tipoManutencaoId,
      dataSolicitacao: DateTime.now(),
      descricao: descricao,
    );
    await _daoManutencao.salvar(m);
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
