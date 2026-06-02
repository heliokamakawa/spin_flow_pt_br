import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/controlador_login.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/infra/navegacao/rotas.dart';
import 'package:spin_flow/infra/autenticacao/sessao_usuario.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_autenticacao.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

class _FakeDAO implements IDAOUsuario {
  Usuario? usuario;

  @override
  Future<Usuario?> buscarPorCredencial({
    required String identificador,
    required String senha,
  }) async => usuario;

  @override
  Future<Usuario?> buscarPorEmail(String email) async => null;

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {}
}

void main() {
  final getIt = GetIt.instance;

  group('ControladorLogin', () {
    late _FakeDAO dao;

    setUp(() {
      dao = _FakeDAO();
      getIt.registerSingleton<IDAOUsuario>(dao);
      getIt.registerSingleton(RepositorioAutenticacao());
    });

    tearDown(() {
      SessaoUsuario.encerrar();
      getIt.reset();
    });

    test('inicia sessao e retorna dashboard da professora', () async {
      dao.usuario = const Usuario(
        id: 1,
        nome: 'Professora',
        email: 'professora@gmail.com',
        cpf: '11122233344',
        professoraId: 1,
        ativo: true,
      );

      final resultado = await ControladorLogin().entrar(
        identificador: 'professora@gmail.com',
        senha: '123',
      );

      expect(resultado.sucesso, isTrue);
      expect(resultado.requerEscolhaPerfil, isTrue);
      expect(resultado.nomeUsuario, 'Professora');
      expect(SessaoUsuario.ativa, isTrue);
      expect(SessaoUsuario.ehProfessora, isTrue);
    });

    test('inicia sessao e retorna dashboard do aluno', () async {
      dao.usuario = const Usuario(
        id: 2,
        nome: 'Ana Clara Almeida',
        email: 'aluna@gmail.com',
        cpf: '55566677788',
        alunoId: 1,
        ativo: true,
      );

      final resultado = await ControladorLogin().entrar(
        identificador: '55566677788',
        senha: '123',
      );

      expect(resultado.sucesso, isTrue);
      expect(resultado.rotaDestino, Rotas.dashboardAluno);
      expect(SessaoUsuario.ativa, isTrue);
      expect(SessaoUsuario.ehAluno, isTrue);
    });

    test('retorna falha quando credenciais sao invalidas', () async {
      final resultado = await ControladorLogin().entrar(
        identificador: 'invalido@email.com',
        senha: 'errada',
      );

      expect(resultado.sucesso, isFalse);
      expect(resultado.mensagemErro, Erro.erroLogin);
      expect(SessaoUsuario.ativa, isFalse);
    });
  });
}
