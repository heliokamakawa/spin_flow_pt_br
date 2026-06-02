import 'package:spin_flow/domain/modelo/fila_espera_checkin.dart';

abstract class IDAOFilaEsperaCheckin {
  Future<void> entrarNaFila(int alunoId, int turmaId, DateTime data);
  Future<int?> buscarPosicaoNaFila(int alunoId, int turmaId, DateTime data);
  Future<int?> buscarIdDoAluno(int alunoId, int turmaId, DateTime data);
  Future<FilaEsperaCheckin?> buscarPrimeiroAtivo(
    int turmaId,
    DateTime data,
  );
  Future<void> sairDaFila(int id);
  Future<int> contarNaFila(int turmaId, DateTime data);
}
