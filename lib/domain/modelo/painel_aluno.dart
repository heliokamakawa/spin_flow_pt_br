import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/nivel_aluno.dart';

class EstatisticasParticipacao {
  final int semana;
  final int mes;
  final int ano;

  EstatisticasParticipacao({
    required this.semana,
    required this.mes,
    required this.ano,
  });
}

/// Indicadores de engajamento do aluno exibidos na aba Meu Painel.
class IndicadoresAluno {
  /// Aulas realizadas no mês atual.
  final int aulasMes;

  /// Semanas distintas do calendário com ao menos 1 aula nos últimos 3 meses.
  final int semanasAtivas;

  /// Total de aulas realizadas nos últimos 3 meses.
  final int totalTresMeses;

  /// Maior sequência de dias consecutivos com aula, terminando na aula mais
  /// recente.
  final int sequenciaAtual;

  /// Semanas seguidas (consecutivas) com ao menos 1 aula, terminando na semana
  /// da aula mais recente. Base para o nível do aluno.
  final int semanasSeguidas;

  IndicadoresAluno({
    required this.aulasMes,
    required this.semanasAtivas,
    required this.totalTresMeses,
    required this.sequenciaAtual,
    required this.semanasSeguidas,
  });

  /// Nível atual derivado das semanas seguidas.
  NivelAluno get nivel => NivelAluno.fromSemanasSeguidas(semanasSeguidas);
}

class PainelAluno {
  final Aluno aluno;
  final EstatisticasParticipacao estatisticas;
  final IndicadoresAluno indicadores;

  /// Último mix em que o aluno participou, com as avaliações já preenchidas.
  /// Null se o aluno ainda não participou de nenhuma aula com mix.
  final MixCheckin? ultimoMix;

  /// Todos os mixes ativos disponíveis para busca e avaliação.
  final List<Mix> mixesDisponiveis;

  PainelAluno({
    required this.aluno,
    required this.estatisticas,
    required this.indicadores,
    required this.ultimoMix,
    required this.mixesDisponiveis,
  });
}
