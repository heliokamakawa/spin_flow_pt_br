import 'package:spin_flow/core/config/erro.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';
import 'package:spin_flow/model/servico/servico_recuperacao_senha.dart';

class ResultadoRecuperacao {
  final bool sucesso;
  final String? mensagemErro;
  final ModeloUsuario? usuario;

  const ResultadoRecuperacao._({
    required this.sucesso,
    this.mensagemErro,
    this.usuario,
  });

  const ResultadoRecuperacao.sucesso({ModeloUsuario? usuario})
    : this._(sucesso: true, usuario: usuario);

  const ResultadoRecuperacao.falha({required String mensagemErro})
    : this._(sucesso: false, mensagemErro: mensagemErro);
}

class ControladorRecuperacaoSenha {
  final ServicoRecuperacaoSenha servico;

  ControladorRecuperacaoSenha({required this.servico});

  Future<ResultadoRecuperacao> verificarEmail(String email) async {
    final usuario = await servico.verificarEmail(email.trim());
    if (usuario == null) {
      return const ResultadoRecuperacao.falha(
        mensagemErro: Erro.emailNaoEncontrado,
      );
    }
    return ResultadoRecuperacao.sucesso(usuario: usuario);
  }

  ResultadoRecuperacao verificarCpf(ModeloUsuario usuario, String cpf) {
    if (!servico.verificarCpf(usuario, cpf)) {
      return const ResultadoRecuperacao.falha(mensagemErro: Erro.cpfNaoConfere);
    }
    return const ResultadoRecuperacao.sucesso();
  }

  Future<ResultadoRecuperacao> redefinirSenha(
    int id,
    String novaSenha,
    String confirmacao,
  ) async {
    if (novaSenha != confirmacao) {
      return const ResultadoRecuperacao.falha(
        mensagemErro: Erro.senhasNaoConferem,
      );
    }
    await servico.redefinirSenha(id, novaSenha);
    return const ResultadoRecuperacao.sucesso();
  }
}
