import 'package:spin_flow/model/gestao_aula/modelo_fila_espera_checkin.dart';

abstract class IDAOFilaEsperaCheckin {
  Future<void> entrarNaFila(int alunoId, int turmaId, DateTime data);
  Future<int?> buscarPosicaoNaFila(int alunoId, int turmaId, DateTime data);
  Future<int?> buscarIdDoAluno(int alunoId, int turmaId, DateTime data);
  Future<ModeloFilaEsperaCheckin?> buscarPrimeiroAtivo(
    int turmaId,
    DateTime data,
  );
  Future<void> sairDaFila(int id);
}
