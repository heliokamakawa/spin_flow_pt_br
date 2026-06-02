import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_recuperacao_senha.dart';

class ResultadoRecuperacao {
  final bool sucesso;
  final String? mensagemErro;
  final Usuario? usuario;

  const ResultadoRecuperacao._({required this.sucesso, this.mensagemErro, this.usuario});
  const ResultadoRecuperacao.sucesso({Usuario? usuario})
    : this._(sucesso: true, usuario: usuario);
  const ResultadoRecuperacao.falha({required String mensagemErro})
    : this._(sucesso: false, mensagemErro: mensagemErro);
}

class ControladorRecuperacaoSenha {
  final _repositorio = RepositorioRecuperacaoSenha();

  Future<ResultadoRecuperacao> verificarEmail(String email) async {
    final usuario = await _repositorio.verificarEmail(email.trim());
    if (usuario == null) {
      return const ResultadoRecuperacao.falha(mensagemErro: Erro.emailNaoEncontrado);
    }
    return ResultadoRecuperacao.sucesso(usuario: usuario);
  }

  ResultadoRecuperacao verificarCpf(Usuario usuario, String cpf) {
    if (!_repositorio.verificarCpf(usuario, cpf)) {
      return const ResultadoRecuperacao.falha(mensagemErro: Erro.cpfNaoConfere);
    }
    return const ResultadoRecuperacao.sucesso();
  }

  Future<ResultadoRecuperacao> redefinirSenha(int id, String novaSenha, String confirmacao) async {
    if (novaSenha != confirmacao) {
      return const ResultadoRecuperacao.falha(mensagemErro: Erro.senhasNaoConferem);
    }
    await _repositorio.redefinirSenha(id, novaSenha);
    return const ResultadoRecuperacao.sucesso();
  }
}
