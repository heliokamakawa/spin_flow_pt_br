import 'package:flutter_test/flutter_test.dart';
import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_usuario_sqlite.dart';

void main() {
  group('DAOUsuarioSQLite', () {
    setUp(() async {
      final dao = DAOUsuarioSQLite();
      final aluno = await dao.buscarPorEmail('aluna@gmail.com');
      if (aluno != null) {
        await dao.atualizarSenha(aluno.id, '123');
      }
    });

    tearDownAll(ConexaoSQLite.fecharConexao);

    test('autentica professora cadastrada no seed SQLite', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.buscarPorCredencial(
        identificador: 'professora@gmail.com',
        senha: '123',
      );

      expect(usuario, isNotNull);
      expect(usuario!.ehProfessora, isTrue);
      expect(usuario.email, 'professora@gmail.com');
    });

    test('autentica aluno pelo CPF cadastrado no seed SQLite', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.buscarPorCredencial(
        identificador: '555.666.777-88',
        senha: '123',
      );

      expect(usuario, isNotNull);
      expect(usuario!.ehAluno, isTrue);
      expect(usuario.cpf, '55566677788');
    });

    test('nao autentica senha invalida', () async {
      final dao = DAOUsuarioSQLite();

      final usuario = await dao.buscarPorCredencial(
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
      final usuario = await dao.buscarPorEmail('aluna@gmail.com');
      expect(usuario, isNotNull);

      await dao.atualizarSenha(usuario!.id, 'nova123');

      final autenticado = await dao.buscarPorCredencial(
        identificador: 'aluna@gmail.com',
        senha: 'nova123',
      );
      expect(autenticado, isNotNull);
      expect(autenticado!.ehAluno, isTrue);

      await dao.atualizarSenha(usuario.id, '123');
    });

    test('seed cria historico coerente de aulas realizadas', () async {
      final db = await ConexaoSQLite.database;

      final totalAulas = await db.rawQuery('''
        SELECT COUNT(*) AS total
        FROM (
          SELECT turma_id, data
          FROM aula_realizada
          GROUP BY turma_id, data
        )
      ''');
      expect(totalAulas.first['total'], 66);

      final totalAssociacoes = await db.rawQuery(
        'SELECT COUNT(*) AS total FROM aula_realizada',
      );
      expect(totalAssociacoes.first['total'], 636);

      final alunosPorAulaMaio = await db.rawQuery('''
        SELECT turma_id, data, COUNT(*) AS total
        FROM aula_realizada
        WHERE substr(data, 1, 7) = '2026-05'
        GROUP BY turma_id, data
      ''');
      expect(alunosPorAulaMaio.length, 30);
      expect(
        alunosPorAulaMaio.every((item) => item['total'] == 20),
        isTrue,
      );

      final frequencias = await db.rawQuery('''
        SELECT aluno_id, COUNT(*) AS total
        FROM aula_realizada
        GROUP BY aluno_id
      ''');
      final porAluno = {
        for (final item in frequencias)
          item['aluno_id'] as int: item['total'] as int,
      };

      expect(porAluno.length, 20);
      expect(porAluno[1], 66);
      expect(
        porAluno.entries
            .where((entry) => entry.key != 1)
            .every((entry) => entry.value == 30),
        isTrue,
      );

      final alunosManhaTarde = await db.rawQuery('''
        SELECT aluno_id
        FROM aula_realizada
        GROUP BY aluno_id
        HAVING SUM(CASE WHEN substr(data, 12, 2) < '12' THEN 1 ELSE 0 END) > 0
           AND SUM(CASE WHEN substr(data, 12, 2) >= '12' THEN 1 ELSE 0 END) > 0
      ''');
      expect(alunosManhaTarde.length, 20);
    });

    test('seed cria avaliacoes de musicas para dois mixes', () async {
      final db = await ConexaoSQLite.database;

      final totalAvaliacoes = await db.rawQuery(
        'SELECT COUNT(*) AS total FROM avaliacao_musica',
      );
      expect(totalAvaliacoes.first['total'], 100);

      final alunosAvaliadores = await db.rawQuery(
        'SELECT COUNT(DISTINCT aluno_id) AS total FROM avaliacao_musica',
      );
      expect(alunosAvaliadores.first['total'], 10);

      final musicasAvaliadas = await db.rawQuery(
        'SELECT COUNT(DISTINCT musica_id) AS total FROM avaliacao_musica',
      );
      expect(musicasAvaliadas.first['total'], 10);
    });
  });
}
