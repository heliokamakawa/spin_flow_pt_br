import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_recuperacao_senha.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

class _FakeDAO implements IDAOUsuario {
  Usuario? usuarioPorEmail;
  int? idAtualizado;
  String? senhaAtualizada;

  @override
  Future<Usuario?> buscarPorCredencial({required String identificador, required String senha}) async => null;

  @override
  Future<Usuario?> buscarPorEmail(String email) async => usuarioPorEmail;

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {
    idAtualizado = id;
    senhaAtualizada = novaSenha;
  }

  @override
  Future<Map<int, String>> buscarNomesProfessoras() async => {};
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

  group('RepositorioRecuperacaoSenha', () {
    late _FakeDAO dao;

    setUp(() {
      dao = _FakeDAO();
      getIt.registerSingleton<IDAOUsuario>(dao);
    });

    tearDown(getIt.reset);

    test('verificarEmail retorna usuario quando email existe', () async {
      dao.usuarioPorEmail = _professora;
      final resultado = await RepositorioRecuperacaoSenha().verificarEmail('professora@gmail.com');
      expect(resultado, isNotNull);
      expect(resultado!.id, 1);
    });

    test('verificarEmail retorna nulo quando email nao existe', () async {
      final resultado = await RepositorioRecuperacaoSenha().verificarEmail('inexistente@email.com');
      expect(resultado, isNull);
    });

    test('verificarCpf retorna true para CPF correto sem formatacao', () {
      expect(RepositorioRecuperacaoSenha().verificarCpf(_professora, '11122233344'), isTrue);
    });

    test('verificarCpf retorna true para CPF correto com formatacao', () {
      expect(RepositorioRecuperacaoSenha().verificarCpf(_professora, '111.222.333-44'), isTrue);
    });

    test('verificarCpf retorna false para CPF incorreto', () {
      expect(RepositorioRecuperacaoSenha().verificarCpf(_professora, '99988877766'), isFalse);
    });

    test('redefinirSenha delega atualizacao ao DAO', () async {
      await RepositorioRecuperacaoSenha().redefinirSenha(1, 'nova123');
      expect(dao.idAtualizado, 1);
      expect(dao.senhaAtualizada, 'nova123');
    });
  });
}
