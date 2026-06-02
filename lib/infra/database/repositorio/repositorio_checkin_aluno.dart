import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_aluno.dart';
import 'package:spin_flow/infra/database/dao/i_dao_avaliacao_musica.dart';
import 'package:spin_flow/infra/database/dao/i_dao_checkin.dart';
import 'package:spin_flow/infra/database/dao/i_dao_fila_espera_checkin.dart';
import 'package:spin_flow/infra/database/dao/i_dao_manutencao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_posicao_bike.dart';
import 'package:spin_flow/infra/database/dao/i_dao_sala.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma_mix.dart';
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
  IDAOTurma             get _daoTurma     => GetIt.I<IDAOTurma>();
  IDAOSala              get _daoSala      => GetIt.I<IDAOSala>();
  IDAOAluno             get _daoAluno     => GetIt.I<IDAOAluno>();
  IDAOCheckin           get _daoCheckin   => GetIt.I<IDAOCheckin>();
  IDAOPosicaoBike       get _daoPosicao   => GetIt.I<IDAOPosicaoBike>();
  IDAOManutencao        get _daoManu      => GetIt.I<IDAOManutencao>();
  IDAOFilaEsperaCheckin get _daoFila      => GetIt.I<IDAOFilaEsperaCheckin>();
  IDAOUsuario           get _daoUsuario   => GetIt.I<IDAOUsuario>();
  IDAOTurmaMix          get _daoTurmaMix  => GetIt.I<IDAOTurmaMix>();
  IDAOAvaliacaoMusica   get _daoAvaliacao => GetIt.I<IDAOAvaliacaoMusica>();

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
      MixCheckin? mix = await _daoTurmaMix.buscarMixDaTurma(turma.id!, dataHoje);
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

    MixCheckin? mix = await _daoTurmaMix.buscarMixDaTurma(turmaId, dataHoje);
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
    );
  }

  Future<String?> reservar({
    required int alunoId,
    required Turma turma,
    required DateTime data,
    required int fila,
    required int coluna,
  }) async {
    final agora = DateTime.now();
    if (!DominioTurma(turma).janelaAberta(agora)) {
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
      if (outra != null && DominioTurma(turma).sobrepoeHorario(outra, data)) {
        return 'Você já tem check-in em ${outra.nome} neste horário.';
      }
    }
    final sala = await _daoSala.buscarPorId(turma.salaId);
    if (sala == null) return 'Sala não encontrada.';
    final posicoes = await _daoPosicao.buscarTodos();
    final bikesManu = await _daoManu.buscarBikeIdsEmManutencaoAtiva();
    final checkinsNaTurma = await _daoCheckin.buscarAtivosPorTurmaData(turma.id!, data);
    if (DominioSala(sala).estaLotada(
      checkinsNaTurma.length,
      posicoes,
      bikesManu,
    )) {
      return 'Turma lotada.';
    }
    if (await _daoCheckin.existeAtivoPorPosicao(turma.id!, data, fila, coluna)) {
      return 'Posição já ocupada.';
    }
    await _daoCheckin.salvar(Checkin(
      alunoId: alunoId,
      turmaId: turma.id!,
      data: data,
      fila: fila,
      coluna: coluna,
    ));
    // Se o aluno estava na fila de espera desta turma, removê-lo
    final filaId = await _daoFila.buscarIdDoAluno(alunoId, turma.id!, data);
    if (filaId != null) await _daoFila.sairDaFila(filaId);
    return null;
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

  Future<void> avaliarMusica(int alunoId, int musicaId, int nota) =>
      _daoAvaliacao.salvar(alunoId, musicaId, nota);
}
