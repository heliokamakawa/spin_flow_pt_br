import 'package:spin_flow/domain/modelo/aula_realizada.dart';

abstract class IDAOAulaRealizada {
  Future<int> contarPorAlunoNoPeriodo(
    int alunoId,
    DateTime inicio,
    DateTime fim,
  );
  Future<AulaRealizada?> buscarUltima(int alunoId);
  Future<void> salvar(AulaRealizada aula);
}
