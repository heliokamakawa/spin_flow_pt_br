import 'package:spin_flow/domain/modelo/aula_realizada.dart';

abstract class IDAOAulaRealizada {
  Future<int> contarPorAlunoNoPeriodo(
    int alunoId,
    DateTime inicio,
    DateTime fim,
  );
  Future<AulaRealizada?> buscarUltima(int alunoId);
  Future<void> salvar(AulaRealizada aula);

  /// Datas distintas (nível de dia) com aula realizada, da mais recente para a
  /// mais antiga. Usado para calcular semanas ativas e sequência de dias.
  Future<List<DateTime>> listarDatasRealizadas(int alunoId);
}
