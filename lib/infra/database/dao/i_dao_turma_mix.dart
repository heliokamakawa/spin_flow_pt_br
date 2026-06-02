import 'package:spin_flow/domain/modelo/mix_checkin.dart';

abstract class IDAOTurmaMix {
  /// Retorna o mix ativo para a turma na data informada, com as músicas
  /// já ordenadas por posição. Retorna null se não houver mix ativo.
  Future<MixCheckin?> buscarMixDaTurma(int turmaId, DateTime data);
}
