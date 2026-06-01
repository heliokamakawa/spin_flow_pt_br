import 'package:spin_flow/model/dao/i_dao_usuario.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';

class ServicoAutenticacao {
  final IDAOUsuario daoUsuario;

  const ServicoAutenticacao({required this.daoUsuario});

  Future<ModeloUsuario?> autenticar({
    required String identificador,
    required String senha,
  }) {
    return daoUsuario.autenticar(identificador: identificador, senha: senha);
  }
}
