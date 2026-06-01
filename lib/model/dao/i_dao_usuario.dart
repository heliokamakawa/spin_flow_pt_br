import 'package:spin_flow/model/modelo/modelo_usuario.dart';

abstract class IDAOUsuario {
  Future<ModeloUsuario?> autenticar({
    required String identificador,
    required String senha,
  });

  Future<ModeloUsuario?> buscarPorEmail(String email);

  Future<void> atualizarSenha(int id, String novaSenha);
}
