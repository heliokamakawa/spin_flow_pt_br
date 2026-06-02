import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_autenticacao.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

class _FakeDAO implements IDAOUsuario {
  Usuario? usuario;

  @override
  Future<Usuario?> buscarPorCredencial({required String identificador, required String senha}) async => usuario;

  @override
  Future<Usuario?> buscarPorEmail(String email) async => null;

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {}
}

void main() {
  final getIt = GetIt.instance;

  group('RepositorioAutenticacao', () {
    late _FakeDAO dao;

    setUp(() {
      dao = _FakeDAO();
      getIt.registerSingleton<IDAOUsuario>(dao);
    });

    tearDown(getIt.reset);

    test('retorna usuario autenticado pelo DAO', () async {
      dao.usuario = const Usuario(
        id: 1,
        nome: 'Professora',
        email: 'professora@gmail.com',
        cpf: '11122233344',
        professoraId: 1,
        ativo: true,
      );

      final usuario = await RepositorioAutenticacao().autenticar(
        identificador: 'professora@gmail.com',
        senha: '123',
      );

      expect(usuario, isNotNull);
      expect(usuario!.ehProfessora, isTrue);
    });

    test('retorna nulo quando DAO nao autentica', () async {
      final usuario = await RepositorioAutenticacao().autenticar(
        identificador: 'invalido@email.com',
        senha: 'errada',
      );
      expect(usuario, isNull);
    });
  });
}
