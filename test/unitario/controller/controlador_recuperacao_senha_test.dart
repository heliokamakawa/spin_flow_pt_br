import 'package:flutter_test/flutter_test.dart';
import 'package:spin_flow/controller/controlador_recuperacao_senha.dart';
import 'package:spin_flow/core/config/erro.dart';
import 'package:spin_flow/model/dao/i_dao_usuario.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';
import 'package:spin_flow/model/servico/servico_recuperacao_senha.dart';

class FakeDAOUsuario implements IDAOUsuario {
  ModeloUsuario? usuarioPorEmail;

  @override
  Future<ModeloUsuario?> autenticar({
    required String identificador,
    required String senha,
  }) async => null;

  @override
  Future<ModeloUsuario?> buscarPorEmail(String email) async =>
      usuarioPorEmail;

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {}
}

const _professora = ModeloUsuario(
  id: 1,
  nome: 'Professora',
  email: 'professora@gmail.com',
  cpf: '11122233344',
  perfil: 'professora',
  ativo: true,
);

void main() {
  group('ControladorRecuperacaoSenha', () {
    late FakeDAOUsuario dao;
    late ControladorRecuperacaoSenha controlador;

    setUp(() {
      dao = FakeDAOUsuario();
      controlador = ControladorRecuperacaoSenha(
        servico: ServicoRecuperacaoSenha(daoUsuario: dao),
      );
    });

    group('verificarEmail', () {
      test('retorna sucesso com usuario quando email existe', () async {
        dao.usuarioPorEmail = _professora;

        final resultado = await controlador.verificarEmail('professora@gmail.com');

        expect(resultado.sucesso, isTrue);
        expect(resultado.usuario, isNotNull);
        expect(resultado.usuario!.id, 1);
      });

      test('retorna falha quando email nao encontrado', () async {
        dao.usuarioPorEmail = null;

        final resultado = await controlador.verificarEmail('nao@existe.com');

        expect(resultado.sucesso, isFalse);
        expect(resultado.mensagemErro, Erro.emailNaoEncontrado);
      });
    });

    group('verificarCpf', () {
      test('retorna sucesso para CPF correto', () {
        final resultado = controlador.verificarCpf(_professora, '111.222.333-44');

        expect(resultado.sucesso, isTrue);
      });

      test('retorna falha para CPF incorreto', () {
        final resultado = controlador.verificarCpf(_professora, '999.888.777-66');

        expect(resultado.sucesso, isFalse);
        expect(resultado.mensagemErro, Erro.cpfNaoConfere);
      });
    });

    group('redefinirSenha', () {
      test('retorna sucesso quando senhas conferem', () async {
        final resultado = await controlador.redefinirSenha(1, 'nova123', 'nova123');

        expect(resultado.sucesso, isTrue);
      });

      test('retorna falha quando senhas nao conferem', () async {
        final resultado = await controlador.redefinirSenha(1, 'nova123', 'diferente');

        expect(resultado.sucesso, isFalse);
        expect(resultado.mensagemErro, Erro.senhasNaoConferem);
      });
    });
  });
}
