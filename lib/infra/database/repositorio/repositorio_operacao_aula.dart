import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/infra/database/dao/i_dao_checkin.dart';
import 'package:spin_flow/infra/database/dao/i_dao_manutencao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_mix.dart';
import 'package:spin_flow/infra/database/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_sala.dart';
import 'package:spin_flow/infra/database/dao/i_dao_tipo_manutencao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/domain/modelo/frequencia_aluno.dart';
import 'package:spin_flow/domain/modelo/manutencao.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/turma.dart';
import 'package:spin_flow/domain/modelo/turma_aluno.dart';

class RepositorioOperacaoAula {
  IDAOTurma          get _daoTurma    => GetIt.I<IDAOTurma>();
  IDAOSala           get _daoSala     => GetIt.I<IDAOSala>();
  IDAOPosicaoBike    get _daoPosicao  => GetIt.I<IDAOPosicaoBike>();
  IDAOCheckin        get _daoCheckin  => GetIt.I<IDAOCheckin>();
  IDAOManutencao     get _daoManu     => GetIt.I<IDAOManutencao>();
  IDAOTipoManutencao get _daoTipo     => GetIt.I<IDAOTipoManutencao>();
  IDAOMix            get _daoMix      => GetIt.I<IDAOMix>();
  IDAOAluno          get _daoAluno    => GetIt.I<IDAOAluno>();

  Future<List<ResumoTurmaHoje>> listarTurmasHoje() async {
    final hoje = _diaSemanaHoje();
    final salas = await _daoSala.buscarTodos();
    final salasPorId = {for (final s in salas) s.id: s.nome};
    final turmas = await _daoTurma.buscarTodos();
    final turmasHoje =
        turmas.where((t) => t.ativo && t.diasSemana.contains(hoje)).toList()
          ..sort((a, b) => a.horarioInicio.compareTo(b.horarioInicio));
    return turmasHoje
        .map((t) => ResumoTurmaHoje(turma: t, nomeSala: salasPorId[t.salaId] ?? ''))
        .toList();
  }

  Future<EstadoMapaAula> carregarMapa(int turmaId) async {
    final turma = await _daoTurma.buscarPorId(turmaId);
    if (turma == null) throw Exception('Turma não encontrada.');
    final sala = await _daoSala.buscarPorId(turma.salaId);
    if (sala == null) throw Exception('Sala não encontrada.');
    final hoje = DateTime.now();
    final data = DateTime(hoje.year, hoje.month, hoje.day);
    final posicoes = await _daoPosicao.buscarTodos();
    final checkins = await _daoCheckin.buscarAtivosPorTurmaData(turmaId, data);
    final bikesManutencao = await _daoManu.buscarBikeIdsEmManutencaoAtiva();
    return EstadoMapaAula(
      turma: turma,
      sala: sala,
      posicoes: posicoes,
      checkinsAtivos: checkins,
      bikeIdsEmManutencao: bikesManutencao,
    );
  }

  Future<List<TipoManutencao>> listarTiposManutencao() =>
      _daoTipo.buscarTodos();

  Future<List<Mix>> listarMixes() async {
    final todos = await _daoMix.buscarTodos();
    return todos.where((m) => m.ativo).toList();
  }

  Future<void> alterarMixTurma(int turmaId, int? mixId) async {
    final turma = await _daoTurma.buscarPorId(turmaId);
    if (turma == null) throw Exception('Turma não encontrada.');
    await _daoTurma.salvar(Turma(
      id: turma.id,
      nome: turma.nome,
      horarioInicio: turma.horarioInicio,
      duracaoMinutos: turma.duracaoMinutos,
      diasSemana: turma.diasSemana,
      salaId: turma.salaId,
      professoraId: turma.professoraId,
      mixId: mixId,
      ativo: turma.ativo,
    ));
  }

  Future<void> cancelarCheckin(int checkinId) =>
      _daoCheckin.cancelar(checkinId);

  Future<void> resolverManutencao(int bikeId) async {
    final m = await _daoManu.buscarManutencaoAtivaPorBikeId(bikeId);
    if (m?.id == null) return;
    await _daoManu.salvar(Manutencao(
      id: m!.id,
      bikeId: m.bikeId,
      tipoManutencaoId: m.tipoManutencaoId,
      dataSolicitacao: m.dataSolicitacao,
      descricao: m.descricao,
      estadoOperacional: EstadoOperacional.realizado,
    ));
  }

  Future<void> registrarManutencao({
    required int bikeId,
    required int tipoManutencaoId,
    required String descricao,
  }) =>
      _daoManu.salvar(Manutencao(
        bikeId: bikeId,
        tipoManutencaoId: tipoManutencaoId,
        dataSolicitacao: DateTime.now(),
        descricao: descricao,
      ));

  Future<List<FrequenciaAluno>> buscarFrequencia(
    int turmaId,
    DateTime inicio,
    DateTime fim,
  ) => _daoCheckin.buscarFrequenciaPorTurma(turmaId, inicio, fim);

  Future<List<FrequenciaAluno>> buscarAlunosPorProfessora(int professoraId) =>
      _daoCheckin.buscarAlunosPorProfessora(professoraId);

  Future<List<TurmaAluno>> buscarTurmasFrequentadasPorAluno(
    int alunoId,
    int professoraId,
  ) => _daoCheckin.buscarTurmasFrequentadasPorAluno(alunoId, professoraId);

  Future<Aluno?> buscarAlunoPorId(int id) => _daoAluno.buscarPorId(id);

  Future<double?> calcularIdadeMediaTurma(int turmaId, DateTime data) =>
      _daoCheckin.calcularIdadeMediaTurma(turmaId, data);

  Future<List<Turma>> listarTurmasAtivas() async {
    final todas = await _daoTurma.buscarTodos();
    final ativas = todas.where((t) => t.ativo).toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
    return ativas;
  }

  DiaSemana _diaSemanaHoje() {
    switch (DateTime.now().weekday) {
      case DateTime.monday: return DiaSemana.segunda;
      case DateTime.tuesday: return DiaSemana.terca;
      case DateTime.wednesday: return DiaSemana.quarta;
      case DateTime.thursday: return DiaSemana.quinta;
      case DateTime.friday: return DiaSemana.sexta;
      case DateTime.saturday: return DiaSemana.sabado;
      default: return DiaSemana.domingo;
    }
  }
}
