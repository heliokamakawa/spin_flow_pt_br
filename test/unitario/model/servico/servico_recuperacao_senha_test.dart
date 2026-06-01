import 'package:flutter_test/flutter_test.dart';
import 'package:spin_flow/model/dao/i_dao_usuario.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';
import 'package:spin_flow/model/servico/servico_recuperacao_senha.dart';

class FakeDAOUsuario implements IDAOUsuario {
  ModeloUsuario? usuarioPorEmail;
  int? idAtualizado;
  String? senhaAtualizada;

  @override
  Future<ModeloUsuario?> autenticar({
    required String identificador,
    required String senha,
  }) async => null;

  @override
  Future<ModeloUsuario?> buscarPorEmail(String email) async =>
      usuarioPorEmail;

  @override
  Future<void> atualizarSenha(int id, String novaSenha) async {
    idAtualizado = id;
    senhaAtualizada = novaSenha;
  }
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
  group('ServicoRecuperacaoSenha', () {
    late FakeDAOUsuario dao;
    late ServicoRecuperacaoSenha servico;

    setUp(() {
      dao = FakeDAOUsuario();
      servico = ServicoRecuperacaoSenha(daoUsuario: dao);
    });

    test('verificarEmail retorna usuario quando email existe', () async {
      dao.usuarioPorEmail = _professora;

      final resultado = await servico.verificarEmail('professora@gmail.com');

      expect(resultado, isNotNull);
      expect(resultado!.id, 1);
    });

    test('verificarEmail retorna nulo quando email nao existe', () async {
      dao.usuarioPorEmail = null;

      final resultado = await servico.verificarEmail('inexistente@email.com');

      expect(resultado, isNull);
    });

    test('verificarCpf retorna true para CPF correto sem formatacao', () {
      expect(servico.verificarCpf(_professora, '11122233344'), isTrue);
    });

    test('verificarCpf retorna true para CPF correto com formatacao', () {
      expect(servico.verificarCpf(_professora, '111.222.333-44'), isTrue);
    });

    test('verificarCpf retorna false para CPF incorreto', () {
      expect(servico.verificarCpf(_professora, '99988877766'), isFalse);
    });

    test('redefinirSenha delega atualizacao ao DAO', () async {
      await servico.redefinirSenha(1, 'nova123');

      expect(dao.idAtualizado, 1);
      expect(dao.senhaAtualizada, 'nova123');
    });
  });
}
