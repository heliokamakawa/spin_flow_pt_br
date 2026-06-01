import 'package:flutter_test/flutter_test.dart';
import 'package:spin_flow/controller/autenticacao/controlador_login.dart';
import 'package:spin_flow/core/config/erro.dart';
import 'package:spin_flow/core/config/rotas.dart';
import 'package:spin_flow/core/config/sessao_usuario.dart';
import 'package:spin_flow/model/dao/i_dao_usuario.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';
import 'package:spin_flow/model/servico/servico_autenticacao.dart';

class FakeDAOUsuario implements IDAOUsuario {
  ModeloUsuario? usuario;

  @override
  Future<ModeloUsuario?> autenticar({
    required String identificador,
    required String senha,
  }) async => usuario;

  @override
  Future<ModeloUsuario?> buscarPorEmail(String email) async => null;

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {}
}

void main() {
  group('ControladorLogin', () {
    tearDown(SessaoUsuario.encerrar);

    test('inicia sessao e retorna dashboard da professora', () async {
      final dao = FakeDAOUsuario()
        ..usuario = const ModeloUsuario(
          id: 1,
          nome: 'Professora',
          email: 'professora@gmail.com',
          cpf: '11122233344',
          perfil: 'professora',
          ativo: true,
        );
      final controlador = ControladorLogin(
        servicoAutenticacao: ServicoAutenticacao(daoUsuario: dao),
      );

      final resultado = await controlador.entrar(
        identificador: 'professora@gmail.com',
        senha: '123',
      );

      expect(resultado.sucesso, isTrue);
      expect(resultado.requerEscolhaPerfil, isTrue);
      expect(resultado.nomeUsuario, 'Professora');
      expect(resultado.rotaDestino, isNull);
      expect(SessaoUsuario.ativa, isTrue);
      expect(SessaoUsuario.ehProfessora, isTrue);
    });

    test('inicia sessao e retorna dashboard do aluno', () async {
      final dao = FakeDAOUsuario()
        ..usuario = const ModeloUsuario(
          id: 2,
          nome: 'Aluno',
          email: 'aluno@gmail.com',
          cpf: '55566677788',
          perfil: 'aluno',
          ativo: true,
        );
      final controlador = ControladorLogin(
        servicoAutenticacao: ServicoAutenticacao(daoUsuario: dao),
      );

      final resultado = await controlador.entrar(
        identificador: '55566677788',
        senha: '123',
      );

      expect(resultado.sucesso, isTrue);
      expect(resultado.rotaDestino, Rotas.dashboardAluno);
      expect(SessaoUsuario.ativa, isTrue);
      expect(SessaoUsuario.ehAluno, isTrue);
    });

    test('retorna falha quando credenciais sao invalidas', () async {
      final controlador = ControladorLogin(
        servicoAutenticacao: ServicoAutenticacao(daoUsuario: FakeDAOUsuario()),
      );

      final resultado = await controlador.entrar(
        identificador: 'invalido@email.com',
        senha: 'errada',
      );

      expect(resultado.sucesso, isFalse);
      expect(resultado.mensagemErro, Erro.erroLogin);
      expect(resultado.rotaDestino, isNull);
      expect(SessaoUsuario.ativa, isFalse);
    });
  });
}
