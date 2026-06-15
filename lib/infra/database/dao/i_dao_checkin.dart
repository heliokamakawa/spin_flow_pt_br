import 'package:spin_flow/domain/modelo/checkin.dart';
import 'package:spin_flow/domain/modelo/frequencia_aluno.dart';
import 'package:spin_flow/domain/modelo/turma_aluno.dart';

abstract class IDAOCheckin {
  Future<List<Checkin>> buscarAtivosPorTurmaData(
    int turmaId,
    DateTime data,
  );
  Future<int> salvar(Checkin checkin);
  Future<bool> existeAtivoPorAluno(int alunoId, int turmaId, DateTime data);
  Future<bool> existeAtivoPorPosicao(
    int turmaId,
    DateTime data,
    int fila,
    int coluna,
  );
  Future<List<Checkin>> buscarAtivosPorAlunoDia(
    int alunoId,
    DateTime data,
  );
  Future<void> cancelar(int id);
  Future<List<FrequenciaAluno>> buscarFrequenciaPorTurma(
    int turmaId,
    DateTime inicio,
    DateTime fim,
  );
  Future<List<FrequenciaAluno>> buscarAlunosPorProfessora(int professoraId);
  Future<List<TurmaAluno>> buscarTurmasFrequentadasPorAluno(
    int alunoId,
    int professoraId,
  );
  Future<double?> calcularIdadeMediaTurma(int turmaId, DateTime data);
}
