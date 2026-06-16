import 'package:spin_flow/domain/modelo/aula_realizada.dart';
import 'package:spin_flow/domain/modelo/registro_historico_aula.dart';

abstract class IDAOAulaRealizada {
  Future<int> contarPorAlunoNoPeriodo(
    int alunoId,
    DateTime inicio,
    DateTime fim,
  );
  Future<AulaRealizada?> buscarUltima(int alunoId);
  Future<void> salvar(AulaRealizada aula);

  /// Lista as aulas realizadas (presenças) do aluno, da mais recente para a
  /// mais antiga, já com nome e horário da turma. Aceita filtro opcional por
  /// data inicial (`a partir de`).
  Future<List<RegistroHistoricoAula>> listarPorAluno(
    int alunoId, {
    DateTime? aPartirDe,
  });
}
