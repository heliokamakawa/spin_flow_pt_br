import 'package:get_it/get_it.dart';
import 'package:spin_flow/domain/modelo/validador_cpf.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

class RepositorioRecuperacaoSenha {
  IDAOUsuario get _dao => GetIt.I<IDAOUsuario>();

  Future<Usuario?> verificarEmail(String email) =>
      _dao.buscarPorEmail(email);

  bool verificarCpf(Usuario usuario, String cpfInformado) =>
      usuario.cpf == ValidadorCpf.normalizar(cpfInformado);

  Future<void> redefinirSenha(int id, String novaSenha) =>
      _dao.atualizarSenha(id, novaSenha);
}
