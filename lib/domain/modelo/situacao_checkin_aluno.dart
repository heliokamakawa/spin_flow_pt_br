import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/turma.dart';

enum StatusCheckinAluno {
  disponivel,    // janela aberta, vagas livres, sem conflito
  janelaFechada, // reserva abre 30 min antes
  confirmado,    // aluno j� tem check-in ativo nesta turma
  lotada,        // turma sem vagas � pode entrar na fila
  emFila,        // aluno est� na fila de espera
  conflito,      // aluno tem check-in ativo em turma simult�nea
}

class SituacaoCheckinAluno {
  final Turma turma;
  final String nomeSala;
  final String? nomeProfessora;
  final MixCheckin? mix;
  final int totalBikes;
  final int vagasDisponiveis;
  final StatusCheckinAluno status;
  final int? posicaoNaFila;
  final String? nomeTurmaConflito;
  final int? totalNaFila;
  final int? checkinId;
  // Bikes fisicamente presentes mas em manutenção ativa (indisponíveis temporariamente)
  final int bikesEmManutencao;

  const SituacaoCheckinAluno({
    required this.turma,
    required this.nomeSala,
    this.nomeProfessora,
    this.mix,
    required this.totalBikes,
    required this.vagasDisponiveis,
    required this.status,
    this.posicaoNaFila,
    this.nomeTurmaConflito,
    this.totalNaFila,
    this.checkinId,
    this.bikesEmManutencao = 0,
  });

  bool get podeFazerCheckin => status == StatusCheckinAluno.disponivel;
  bool get podeCancelar => status == StatusCheckinAluno.confirmado;
  bool get podeEntrarNaFila => status == StatusCheckinAluno.lotada;
  bool get podeSairDaFila => status == StatusCheckinAluno.emFila;
  bool get alunoNaFila => posicaoNaFila != null;
  bool get bloqueado =>
      status == StatusCheckinAluno.conflito ||
      status == StatusCheckinAluno.janelaFechada;

  // Spots já ocupados por check-ins (sobre a capacidade efetiva)
  int get vagasOcupadas => totalBikes - vagasDisponiveis;
  // X/Y onde X = check-ins e Y = capacidade efetiva (sem professora e sem manutenção)
  String get textoOcupacao => '$vagasOcupadas/$totalBikes';

  String get labelBotao => switch (status) {
    StatusCheckinAluno.disponivel    => 'Check-in',
    StatusCheckinAluno.lotada        => 'Entrar na Fila',
    StatusCheckinAluno.janelaFechada => 'Aguardando',
    StatusCheckinAluno.confirmado    => 'Cancelar Check-in',
    StatusCheckinAluno.emFila        => 'Na Fila · #$posicaoNaFila',
    StatusCheckinAluno.conflito      => 'Conflito de Horário',
  };

  bool get botaoAtivo =>
      status == StatusCheckinAluno.disponivel ||
      status == StatusCheckinAluno.lotada ||
      status == StatusCheckinAluno.confirmado;
}
