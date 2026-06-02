import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/controlador_recuperacao_senha.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_recuperacao_senha.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

class _FakeDAO implements IDAOUsuario {
  Usuario? usuarioPorEmail;

  @override
  Future<Usuario?> buscarPorCredencial({required String identificador, required String senha}) async => null;

  @override
  Future<Usuario?> buscarPorEmail(String email) async => usuarioPorEmail;

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {}
}

const _professora = Usuario(
  id: 1,
  nome: 'Professora',
  email: 'professora@gmail.com',
  cpf: '11122233344',
  professoraId: 1,
  ativo: true,
);

void main() {
  final getIt = GetIt.instance;

  group('ControladorRecuperacaoSenha', () {
    late _FakeDAO dao;

    setUp(() {
      dao = _FakeDAO();
      getIt.registerSingleton<IDAOUsuario>(dao);
      getIt.registerSingleton(RepositorioRecuperacaoSenha());
    });

    tearDown(getIt.reset);

    group('verificarEmail', () {
      test('retorna sucesso com usuario quando email existe', () async {
        dao.usuarioPorEmail = _professora;
        final resultado = await ControladorRecuperacaoSenha().verificarEmail('professora@gmail.com');
        expect(resultado.sucesso, isTrue);
        expect(resultado.usuario?.id, 1);
      });

      test('retorna falha quando email nao encontrado', () async {
        final resultado = await ControladorRecuperacaoSenha().verificarEmail('nao@existe.com');
        expect(resultado.sucesso, isFalse);
        expect(resultado.mensagemErro, Erro.emailNaoEncontrado);
      });
    });

    group('verificarCpf', () {
      test('retorna sucesso para CPF correto', () {
        final resultado = ControladorRecuperacaoSenha().verificarCpf(_professora, '111.222.333-44');
        expect(resultado.sucesso, isTrue);
      });

      test('retorna falha para CPF incorreto', () {
        final resultado = ControladorRecuperacaoSenha().verificarCpf(_professora, '999.888.777-66');
        expect(resultado.sucesso, isFalse);
        expect(resultado.mensagemErro, Erro.cpfNaoConfere);
      });
    });

    group('redefinirSenha', () {
      test('retorna sucesso quando senhas conferem', () async {
        final resultado = await ControladorRecuperacaoSenha().redefinirSenha(1, 'nova123', 'nova123');
        expect(resultado.sucesso, isTrue);
      });

      test('retorna falha quando senhas nao conferem', () async {
        final resultado = await ControladorRecuperacaoSenha().redefinirSenha(1, 'nova123', 'diferente');
        expect(resultado.sucesso, isFalse);
        expect(resultado.mensagemErro, Erro.senhasNaoConferem);
      });
    });
  });
}
