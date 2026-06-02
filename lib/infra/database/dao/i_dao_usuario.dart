import 'package:spin_flow/domain/modelo/usuario.dart';

abstract class IDAOUsuario {
  Future<Usuario?> buscarPorCredencial({
    required String identificador,
    required String senha,
  });

  Future<Usuario?> buscarPorEmail(String email);

  Future<void> atualizarSenha(int id, String novaSenha);

  /// Retorna mapa de professoraId → nome para todas as professoras ativas.
  Future<Map<int, String>> buscarNomesProfessoras();
}
