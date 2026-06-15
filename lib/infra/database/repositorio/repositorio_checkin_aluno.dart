import 'package:get_it/get_it.dart';
import 'package:spin_flow/domain/modelo/painel_aluno.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aula_realizada.dart';
import 'package:spin_flow/infra/database/dao/i_dao_avaliacao_musica.dart';
import 'package:spin_flow/infra/database/dao/i_dao_mix.dart';
import 'package:spin_flow/infra/database/dao/i_dao_checkin.dart';
import 'package:spin_flow/infra/database/dao/i_dao_fila_espera_checkin.dart';
import 'package:spin_flow/infra/database/dao/i_dao_manutencao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_sala.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/musica_checkin.dart';
import 'package:spin_flow/domain/dominio/dominio_sala.dart';
import 'package:spin_flow/domain/dominio/dominio_turma.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/checkin.dart';
import 'package:spin_flow/domain/modelo/turma.dart';
import 'package:spin_flow/domain/modelo/situacao_checkin_aluno.dart';

class RepositorioCheckinAluno {
  IDAOTurma             get _daoTurma        => GetIt.I<IDAOTurma>();
  IDAOSala              get _daoSala         => GetIt.I<IDAOSala>();
  IDAOAluno             get _daoAluno        => GetIt.I<IDAOAluno>();
  IDAOCheckin           get _daoCheckin      => GetIt.I<IDAOCheckin>();
  IDAOPosicaoBike       get _daoPosicao      => GetIt.I<IDAOPosicaoBike>();
  IDAOManutencao        get _daoManu         => GetIt.I<IDAOManutencao>();
  IDAOFilaEsperaCheckin get _daoFila         => GetIt.I<IDAOFilaEsperaCheckin>();
  IDAOUsuario           get _daoUsuario      => GetIt.I<IDAOUsuario>();
  IDAOAvaliacaoMusica   get _daoAvaliacao    => GetIt.I<IDAOAvaliacaoMusica>();
  IDAOAulaRealizada     get _daoAulaRealizada => GetIt.I<IDAOAulaRealizada>();
  IDAOMix               get _daoMix           => GetIt.I<IDAOMix>();

  Future<Aluno?> buscarAlunoPorEmail(String email) =>
      _daoAluno.buscarPorEmail(email);

  Future<List<SituacaoCheckinAluno>> listarTurmasHoje(int alunoId) async {
    final agora = DateTime.now();
    final dataHoje = DateTime(agora.year, agora.month, agora.day);

    final salas = await _daoSala.buscarTodos();
    final salasPorId = {for (final s in salas) s.id: s};
    final todasPosicoes = await _daoPosicao.buscarTodos();
    final bikesManutencao = await _daoManu.buscarBikeIdsEmManutencaoAtiva();
    final nomesProfessoras = await _daoUsuario.buscarNomesProfessoras();

    final turmas = await _daoTurma.buscarTodos();
    final turmasHoje = turmas
        .where((t) {
          final dominio = DominioTurma(t);
          return t.ativo &&
              dominio.ocorreEm(DiaSemana.hoje()) &&
              !dominio.jaEncerrou(agora);
        })
        .toList()
      ..sort((a, b) => a.horarioInicio.compareTo(b.horarioInicio));

    final checkinsAluno = await _daoCheckin.buscarAtivosPorAlunoDia(alunoId, dataHoje);
    final turmasPorId = {for (final t in turmas) t.id: t};
    final resultado = <SituacaoCheckinAluno>[];

    for (final turma in turmasHoje) {
      final sala = salasPorId[turma.salaId];
      if (sala == null) continue;

      // Capacidade efetiva: sem professora e sem manutenção (= vagas reserváveis)
      final totalBikes =
          DominioSala(sala).bikesDisponiveis(todasPosicoes, bikesManutencao);
      // Quantas bikes estão em manutenção nesta sala (informação extra para o aluno)
      final nManutencao =
          DominioSala(sala).bikesDisponiveis(todasPosicoes, const {}) - totalBikes;
      final checkinsNaTurma =
          await _daoCheckin.buscarAtivosPorTurmaData(turma.id!, dataHoje);
      final vagas =
          (totalBikes - checkinsNaTurma.length).clamp(0, totalBikes);

      StatusCheckinAluno status;
      String? nomeTurmaConflito;
      int? posicaoNaFila;
      int? checkinId;

      final meuCheckinNaTurma =
          checkinsNaTurma.where((c) => c.alunoId == alunoId).firstOrNull;
      if (meuCheckinNaTurma != null) {
        status = StatusCheckinAluno.confirmado;
        checkinId = meuCheckinNaTurma.id;
      } else {
        posicaoNaFila = await _daoFila.buscarPosicaoNaFila(alunoId, turma.id!, dataHoje);
        if (posicaoNaFila != null) {
          status = StatusCheckinAluno.emFila;
        } else {
          Checkin? conflito;
          for (final c in checkinsAluno) {
            if (c.turmaId == turma.id) continue;
            final outra = turmasPorId[c.turmaId];
            if (outra != null &&
                DominioTurma(turma).sobrepoeHorario(outra, dataHoje)) {
              conflito = c;
              break;
            }
          }
          if (conflito != null) {
            status = StatusCheckinAluno.conflito;
            nomeTurmaConflito = turmasPorId[conflito.turmaId]?.nome;
          } else if (vagas == 0) {
            status = StatusCheckinAluno.lotada;
          } else if (!DominioTurma(turma).janelaAberta(agora)) {
            status = StatusCheckinAluno.janelaFechada;
          } else {
            status = StatusCheckinAluno.disponivel;
          }
        }
      }

      // Mix + avaliações do aluno
      MixCheckin? mix = await _daoMix.buscarMixDaTurma(turma.id!);
      if (mix != null && mix.musicas.isNotEmpty) {
        final musicaIds = mix.musicas.map((m) => m.musicaId).toList();
        final avaliacoes = await _daoAvaliacao.buscarAvaliacoesAluno(alunoId, musicaIds);
        mix = MixCheckin(
          mixId: mix.mixId,
          nomeMix: mix.nomeMix,
          musicas: mix.musicas
              .map((m) => MusicaCheckin(
                    musicaId: m.musicaId,
                    posicao: m.posicao,
                    nome: m.nome,
                    nomeArtista: m.nomeArtista,
                    avaliacao: avaliacoes[m.musicaId],
                  ))
              .toList(),
        );
      }

      int? totalNaFila;
      if (status == StatusCheckinAluno.lotada ||
          status == StatusCheckinAluno.emFila) {
        totalNaFila = await _daoFila.contarNaFila(turma.id!, dataHoje);
      }

      resultado.add(SituacaoCheckinAluno(
        turma: turma,
        nomeSala: sala.nome,
        nomeProfessora: turma.professoraId != null
            ? nomesProfessoras[turma.professoraId]
            : null,
        mix: mix,
        totalBikes: totalBikes,
        vagasDisponiveis: vagas,
        status: status,
        posicaoNaFila: posicaoNaFila,
        nomeTurmaConflito: nomeTurmaConflito,
        totalNaFila: totalNaFila,
        checkinId: checkinId,
        bikesEmManutencao: nManutencao,
      ));
    }
    return resultado;
  }

  Future<MapaCheckinAluno> carregarMapa(int turmaId, int alunoId) async {
    final turma = await _daoTurma.buscarPorId(turmaId);
    if (turma == null) throw Exception('Turma não encontrada.');
    final sala = await _daoSala.buscarPorId(turma.salaId);
    if (sala == null) throw Exception('Sala não encontrada.');

    final agora = DateTime.now();
    final dataHoje = DateTime(agora.year, agora.month, agora.day);

    final posicoesFt         = _daoPosicao.buscarTodos();
    final checkinsFt         = _daoCheckin.buscarAtivosPorTurmaData(turmaId, dataHoje);
    final bikesManuFt        = _daoManu.buscarBikeIdsEmManutencaoAtiva();
    final motivosFt          = _daoManu.buscarDescricoesAtivas();
    final nomesProfessorasFt = _daoUsuario.buscarNomesProfessoras();

    final posicoes         = await posicoesFt;
    final checkins         = await checkinsFt;
    final bikesManutencao  = await bikesManuFt;
    final motivosManutencao = await motivosFt;
    final nomesProfessoras = await nomesProfessorasFt;

    final mapa = EstadoMapaAula(
      turma: turma,
      sala: sala,
      posicoes: posicoes,
      checkinsAtivos: checkins,
      bikeIdsEmManutencao: bikesManutencao,
      motivosManutencao: motivosManutencao,
    );

    final meuCheckin  = checkins.where((c) => c.alunoId == alunoId).firstOrNull;
    final posicaoFila = await _daoFila.buscarPosicaoNaFila(alunoId, turmaId, dataHoje);
    final filaId      = await _daoFila.buscarIdDoAluno(alunoId, turmaId, dataHoje);
    final totalNaFila = mapa.lotada
        ? await _daoFila.contarNaFila(turmaId, dataHoje)
        : 0;

    MixCheckin? mix = await _daoMix.buscarMixDaTurma(turmaId);
    if (mix != null && mix.musicas.isNotEmpty) {
      final musicaIds = mix.musicas.map((m) => m.musicaId).toList();
      final avaliacoes = await _daoAvaliacao.buscarAvaliacoesAluno(alunoId, musicaIds);
      mix = MixCheckin(
        mixId: mix.mixId,
        nomeMix: mix.nomeMix,
        musicas: mix.musicas
            .map((m) => MusicaCheckin(
                  musicaId: m.musicaId,
                  posicao: m.posicao,
                  nome: m.nome,
                  nomeArtista: m.nomeArtista,
                  avaliacao: avaliacoes[m.musicaId],
                ))
            .toList(),
      );
    }

    return MapaCheckinAluno(
      mapa: mapa,
      alunoId: alunoId,
      janelAberta: DominioTurma(turma).janelaAberta(agora),
      idCheckinDoAluno: meuCheckin?.id,
      posicaoNaFila: posicaoFila,
      filaId: filaId,
      nomeProfessora: turma.professoraId != null
          ? nomesProfessoras[turma.professoraId]
          : null,
      mix: mix,
      totalNaFila: totalNaFila,
    );
  }

  Future<Aluno?> buscarAluno(int id) => _daoAluno.buscarPorId(id);

  Future<List<Checkin>> buscarCheckinsAlunoDia(int alunoId, DateTime data) =>
      _daoCheckin.buscarAtivosPorAlunoDia(alunoId, data);

  Future<Map<int, Turma>> buscarTurmasPorId() async {
    final todas = await _daoTurma.buscarTodos();
    return {for (final t in todas) if (t.id != null) t.id!: t};
  }

  Future<List<Checkin>> buscarCheckinsNaTurma(int turmaId, DateTime data) =>
      _daoCheckin.buscarAtivosPorTurmaData(turmaId, data);

  Future<int> calcularVagas(int salaId, List<Checkin> checkinsNaTurma) async {
    final sala = await _daoSala.buscarPorId(salaId);
    if (sala == null) return 0;
    final posicoes = await _daoPosicao.buscarTodos();
    final bikesManu = await _daoManu.buscarBikeIdsEmManutencaoAtiva();
    final total = DominioSala(sala).bikesDisponiveis(posicoes, bikesManu);
    return (total - checkinsNaTurma.length).clamp(0, total);
  }

  Future<void> persistirCheckin(Checkin checkin) async {
    await _daoCheckin.salvar(checkin);
    final filaId = await _daoFila.buscarIdDoAluno(checkin.alunoId, checkin.turmaId, checkin.data);
    if (filaId != null) await _daoFila.sairDaFila(filaId);
  }

  Future<void> cancelarMinha(int checkinId) => _daoCheckin.cancelar(checkinId);

  Future<String?> entrarFilaEspera(int alunoId, int turmaId, DateTime data) async {
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

  Future<List<String>> buscarNomesNaFila(int turmaId) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return _daoFila.buscarNomesNaFila(turmaId, hoje);
  }

  Future<void> avaliarMusica(int alunoId, int musicaId, int nota) =>
      _daoAvaliacao.salvar(alunoId, musicaId, nota);

  Future<PainelAluno?> buscarPainelAluno(int alunoId) async {
    final aluno = await _daoAluno.buscarPorId(alunoId);
    if (aluno == null) return null;

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
    final inicioMes = DateTime(agora.year, agora.month, 1);
    final inicioAno = DateTime(agora.year, 1, 1);

    final semanaFt = _daoAulaRealizada.contarPorAlunoNoPeriodo(alunoId, inicioSemana, hoje);
    final mesFt    = _daoAulaRealizada.contarPorAlunoNoPeriodo(alunoId, inicioMes, hoje);
    final anoFt    = _daoAulaRealizada.contarPorAlunoNoPeriodo(alunoId, inicioAno, hoje);
    final ultimaAulaFt   = _daoAulaRealizada.buscarUltima(alunoId);
    final mixesDisponiveisFt = _daoMix.buscarTodos();

    final semana           = await semanaFt;
    final mes              = await mesFt;
    final ano              = await anoFt;
    final ultimaAula       = await ultimaAulaFt;
    final mixesDisponiveis = (await mixesDisponiveisFt).where((m) => m.ativo).toList();

    MixCheckin? ultimoMix;
    if (ultimaAula != null) {
      final mixSemRatings = await _daoMix.buscarMixDaTurma(ultimaAula.turmaId);
      if (mixSemRatings != null && mixSemRatings.musicas.isNotEmpty) {
        final musicaIds = mixSemRatings.musicas.map((m) => m.musicaId).toList();
        final ratings   = await _daoAvaliacao.buscarAvaliacoesAluno(alunoId, musicaIds);
        ultimoMix = MixCheckin(
          mixId: mixSemRatings.mixId,
          nomeMix: mixSemRatings.nomeMix,
          musicas: mixSemRatings.musicas
              .map((m) => MusicaCheckin(
                    musicaId: m.musicaId,
                    posicao: m.posicao,
                    nome: m.nome,
                    nomeArtista: m.nomeArtista,
                    avaliacao: ratings[m.musicaId],
                  ))
              .toList(),
        );
      }
    }

    return PainelAluno(
      aluno: aluno,
      estatisticas: EstatisticasParticipacao(semana: semana, mes: mes, ano: ano),
      ultimoMix: ultimoMix,
      mixesDisponiveis: mixesDisponiveis,
    );
  }

  Future<MixCheckin?> buscarMixComAvaliacoes(int mixId, int alunoId) async {
    final mixSemRatings = await _daoMix.buscarMixPorId(mixId);
    if (mixSemRatings == null || mixSemRatings.musicas.isEmpty) return null;
    final musicaIds = mixSemRatings.musicas.map((m) => m.musicaId).toList();
    final ratings   = await _daoAvaliacao.buscarAvaliacoesAluno(alunoId, musicaIds);
    return MixCheckin(
      mixId: mixSemRatings.mixId,
      nomeMix: mixSemRatings.nomeMix,
      musicas: mixSemRatings.musicas
          .map((m) => MusicaCheckin(
                musicaId: m.musicaId,
                posicao: m.posicao,
                nome: m.nome,
                nomeArtista: m.nomeArtista,
                avaliacao: ratings[m.musicaId],
              ))
          .toList(),
    );
  }
}
