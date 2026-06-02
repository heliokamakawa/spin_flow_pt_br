import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

class RepositorioAutenticacao {
  IDAOUsuario get _dao => GetIt.I<IDAOUsuario>();

  Future<Usuario?> autenticar({
    required String identificador,
    required String senha,
  }) async {
    final usuario = await _dao.buscarPorCredencial(
      identificador: identificador,
      senha: senha,
    );
    if (usuario == null) return null;
    if (!usuario.valido) return null;
    return usuario;
  }
}
