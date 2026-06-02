import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';

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

class PainelAluno {
  final Aluno aluno;
  final EstatisticasParticipacao estatisticas;

  /// Último mix em que o aluno participou, com as avaliações já preenchidas.
  /// Null se o aluno ainda não participou de nenhuma aula com mix.
  final MixCheckin? ultimoMix;

  /// Todos os mixes ativos disponíveis para busca e avaliação.
  final List<Mix> mixesDisponiveis;

  PainelAluno({
    required this.aluno,
    required this.estatisticas,
    required this.ultimoMix,
    required this.mixesDisponiveis,
  });
}
