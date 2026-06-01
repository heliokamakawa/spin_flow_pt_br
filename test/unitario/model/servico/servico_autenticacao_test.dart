import 'package:flutter_test/flutter_test.dart';
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
  group('ServicoAutenticacao', () {
    test('retorna usuario autenticado pelo DAO', () async {
      final dao = FakeDAOUsuario()
        ..usuario = const ModeloUsuario(
          id: 1,
          nome: 'Professora',
          email: 'professora@gmail.com',
          cpf: '11122233344',
          perfil: 'professora',
          ativo: true,
        );
      final servico = ServicoAutenticacao(daoUsuario: dao);

      final usuario = await servico.autenticar(
        identificador: 'professora@gmail.com',
        senha: '123',
      );

      expect(usuario, isNotNull);
      expect(usuario!.ehProfessora, isTrue);
    });

    test('retorna nulo quando DAO nao autentica', () async {
      final servico = ServicoAutenticacao(daoUsuario: FakeDAOUsuario());

      final usuario = await servico.autenticar(
        identificador: 'invalido@email.com',
        senha: 'errada',
      );

      expect(usuario, isNull);
    });
  });
}
