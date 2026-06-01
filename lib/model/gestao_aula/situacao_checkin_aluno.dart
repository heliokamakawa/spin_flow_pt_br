import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';

enum StatusCheckinAluno {
  disponivel,    // janela aberta, vagas livres, sem conflito
  janelaFechada, // reserva abre 30 min antes
  confirmado,    // aluno já tem check-in ativo nesta turma
  lotada,        // turma sem vagas — pode entrar na fila
  emFila,        // aluno está na fila de espera
  conflito,      // aluno tem check-in ativo em turma simultânea
}

class SituacaoCheckinAluno {
  final ModeloTurma turma;
  final String nomeSala;
  final int totalBikes;
  final int vagasDisponiveis;
  final StatusCheckinAluno status;
  final int? posicaoNaFila;
  final String? nomeTurmaConflito;

  const SituacaoCheckinAluno({
    required this.turma,
    required this.nomeSala,
    required this.totalBikes,
    required this.vagasDisponiveis,
    required this.status,
    this.posicaoNaFila,
    this.nomeTurmaConflito,
  });

  bool get podeFazerCheckin => status == StatusCheckinAluno.disponivel;
  bool get podeCancelar => status == StatusCheckinAluno.confirmado;
  bool get podeEntrarNaFila => status == StatusCheckinAluno.lotada;
  bool get podeSairDaFila => status == StatusCheckinAluno.emFila;
  bool get alunoNaFila => posicaoNaFila != null;
  bool get bloqueado =>
      status == StatusCheckinAluno.conflito ||
      status == StatusCheckinAluno.janelaFechada;
}
