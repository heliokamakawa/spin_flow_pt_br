import 'package:spin_flow/core/validacoes/validador_cpf.dart';
import 'package:spin_flow/model/dao/i_dao_usuario.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';

class ServicoRecuperacaoSenha {
  final IDAOUsuario daoUsuario;

  const ServicoRecuperacaoSenha({required this.daoUsuario});

  Future<ModeloUsuario?> verificarEmail(String email) {
    return daoUsuario.buscarPorEmail(email);
  }

  bool verificarCpf(ModeloUsuario usuario, String cpfInformado) {
    return usuario.cpf == ValidadorCpf.normalizar(cpfInformado);
  }

  Future<void> redefinirSenha(int id, String novaSenha) {
    return daoUsuario.atualizarSenha(id, novaSenha);
  }
}
