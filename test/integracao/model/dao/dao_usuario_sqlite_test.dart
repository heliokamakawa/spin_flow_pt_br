import 'package:flutter_test/flutter_test.dart';
import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/sqlite/dao_usuario_sqlite.dart';

void main() {
  group('DAOUsuarioSQLite', () {
    setUp(() async {
      final dao = DAOUsuarioSQLite();
      final aluno = await dao.buscarPorEmail('aluno@gmail.com');
      if (aluno != null) {
        await dao.atualizarSenha(aluno.id, '123');
      }
    });

    tearDownAll(ConexaoSQLite.fecharConexao);

    test('autentica professora cadastrada no seed SQLite', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.autenticar(
        identificador: 'professora@gmail.com',
        senha: '123',
      );

      expect(usuario, isNotNull);
      expect(usuario!.ehProfessora, isTrue);
      expect(usuario.email, 'professora@gmail.com');
    });

    test('autentica aluno pelo CPF cadastrado no seed SQLite', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.autenticar(
        identificador: '555.666.777-88',
        senha: '123',
      );

      expect(usuario, isNotNull);
      expect(usuario!.ehAluno, isTrue);
      expect(usuario.cpf, '55566677788');
    });

    test('nao autentica senha invalida', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.autenticar(
        identificador: 'professora@gmail.com',
        senha: 'senha-errada',
      );

      expect(usuario, isNull);
    });

    test('buscarPorEmail retorna usuario ativo', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.buscarPorEmail('professora@gmail.com');

      expect(usuario, isNotNull);
      expect(usuario!.ehProfessora, isTrue);
    });

    test('buscarPorEmail retorna nulo para email inexistente', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.buscarPorEmail('naoexiste@email.com');

      expect(usuario, isNull);
    });

    test('atualizarSenha permite autenticar com nova senha', () async {
      final dao = DAOUsuarioSQLite();
      final usuario = await dao.buscarPorEmail('aluno@gmail.com');
      expect(usuario, isNotNull);

      await dao.atualizarSenha(usuario!.id, 'nova123');

      final autenticado = await dao.autenticar(
        identificador: 'aluno@gmail.com',
        senha: 'nova123',
      );
      expect(autenticado, isNotNull);
      expect(autenticado!.ehAluno, isTrue);

      await dao.atualizarSenha(usuario.id, '123');
    });
  });
}
