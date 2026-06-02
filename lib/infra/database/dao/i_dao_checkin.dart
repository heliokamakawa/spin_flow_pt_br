import 'package:spin_flow/domain/modelo/checkin.dart';

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
}
