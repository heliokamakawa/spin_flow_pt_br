import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/mix_repertorio_professora.dart';

abstract class IDAOMix {
  Future<List<Mix>> buscarTodos();
  Future<Mix?> buscarPorId(int id);
  Future<int> salvar(Mix mix);
  Future<void> excluir(int id);

  Future<MixCheckin?> buscarMixDaTurma(int turmaId);
  Future<MixCheckin?> buscarMixPorId(int mixId);
  Future<MixRepertorioProfessora?> buscarMixComMediasPorId(int mixId);
}
