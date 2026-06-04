import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/infra/config/rotas.dart';
import 'package:spin_flow/controller/sessao_usuario.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_autenticacao.dart';

class ResultadoLogin {
  final bool sucesso;
  final String? mensagemErro;
  final String? rotaDestino;
  final bool requerEscolhaPerfil;
  final String? nomeUsuario;

  const ResultadoLogin._({
    required this.sucesso,
    this.mensagemErro,
    this.rotaDestino,
    this.requerEscolhaPerfil = false,
    this.nomeUsuario,
  });

  const ResultadoLogin.sucesso({required String rotaDestino})
    : this._(sucesso: true, rotaDestino: rotaDestino);

  const ResultadoLogin.escolhaPerfil({required String nomeUsuario})
    : this._(sucesso: true, requerEscolhaPerfil: true, nomeUsuario: nomeUsuario);

  const ResultadoLogin.falha({required String mensagemErro})
    : this._(sucesso: false, mensagemErro: mensagemErro);
}

class ControladorLogin {
  final _repositorio = RepositorioAutenticacao();

  Future<ResultadoLogin> entrar({
    required String identificador,
    required String senha,
  }) async {
    final usuario = await _repositorio.autenticar(
      identificador: identificador,
      senha: senha,
    );
    if (usuario == null) {
      return const ResultadoLogin.falha(mensagemErro: Erro.erroLogin);
    }
    SessaoUsuario.iniciar(
      id: usuario.id,
      nomeUsuario: usuario.nome,
      emailUsuario: usuario.email,
      perfilUsuario: usuario.perfil,
      alunoId: usuario.alunoId,
      professoraId: usuario.professoraId,
    );
    if (usuario.ehProfessora) {
      return ResultadoLogin.escolhaPerfil(nomeUsuario: usuario.nome);
    }
    return ResultadoLogin.sucesso(rotaDestino: Rotas.dashboardAluno);
  }
}
