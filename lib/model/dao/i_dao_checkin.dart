import 'package:spin_flow/model/gestao_aula/modelo_checkin.dart';

abstract class IDAOCheckin {
  Future<List<ModeloCheckin>> buscarAtivosPorTurmaData(
    int turmaId,
    DateTime data,
  );
  Future<int> salvar(ModeloCheckin checkin);
  Future<bool> existeAtivoPorAluno(int alunoId, int turmaId, DateTime data);
  Future<bool> existeAtivoPorPosicao(
    int turmaId,
    DateTime data,
    int fila,
    int coluna,
  );
  Future<void> cancelar(int id);
}
