import 'package:spin_flow/domain/dominio/dominio_turma.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/checkin.dart';
import 'package:spin_flow/domain/modelo/turma.dart';

class DominioCheckin {
  final Checkin modelo;

  const DominioCheckin(this.modelo);

  // Regra pura: data não pode ser passada (não precisa de dado externo)
  String? validarRegras() {
    final hoje = DateTime.now();
    final dataAula = DateTime(modelo.data.year, modelo.data.month, modelo.data.day);
    final dataHoje = DateTime(hoje.year, hoje.month, hoje.day);
    if (dataAula.isBefore(dataHoje)) return 'Não é possível reservar para datas passadas.';
    return null;
  }

  // Janela abre 30 min antes da aula
  String? validarJanela(Turma turma) {
    if (!DominioTurma(turma).janelaAberta(DateTime.now())) {
      return 'Reserva disponível 30 min antes da aula.';
    }
    return null;
  }

  // Aluno deve estar ativo
  String? validarAluno(Aluno aluno) {
    if (!aluno.ativo) return 'Aluno inativo.';
    return null;
  }

  // Não pode ter outra reserva ativa na mesma turma+data
  String? validarDuplicata(List<Checkin> checkinsDoAluno) {
    if (checkinsDoAluno.any((c) => c.turmaId == modelo.turmaId)) {
      return 'Você já tem reserva nesta turma.';
    }
    return null;
  }

  // Não pode ter check-in em turma com horário sobreposto
  String? validarConflito(
    Turma turma,
    List<Checkin> checkinsDoAluno,
    Map<int, Turma> turmasPorId,
  ) {
    for (final c in checkinsDoAluno) {
      if (c.turmaId == modelo.turmaId) continue;
      final outra = turmasPorId[c.turmaId];
      if (outra != null && DominioTurma(turma).sobrepoeHorario(outra, modelo.data)) {
        return 'Conflito de horário com "${outra.nome}".';
      }
    }
    return null;
  }

  // Turma não pode estar lotada
  String? validarVagas(int vagasDisponiveis) {
    if (vagasDisponiveis <= 0) return 'Turma lotada.';
    return null;
  }

  // Posição não pode estar ocupada
  String? validarPosicao(List<Checkin> checkinsNaTurma) {
    if (checkinsNaTurma.any((c) => c.fila == modelo.fila && c.coluna == modelo.coluna)) {
      return 'Posição já ocupada.';
    }
    return null;
  }

  String? validar() => validarRegras();
}
