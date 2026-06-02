import 'package:spin_flow/domain/modelo/mix_checkin.dart';

abstract class IDAOTurmaMix {
  Future<MixCheckin?> buscarMixDaTurma(int turmaId, DateTime data);
  Future<MixCheckin?> buscarMixPorId(int mixId);
}
