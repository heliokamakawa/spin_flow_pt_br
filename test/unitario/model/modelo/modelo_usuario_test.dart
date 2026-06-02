import 'package:flutter_test/flutter_test.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';

void main() {
  group('Usuario', () {
    test('identifica perfil professora', () {
      const usuario = Usuario(
        id: 1,
        nome: 'Professora',
        email: 'professora@gmail.com',
        cpf: '11122233344',
        professoraId: 1,
        ativo: true,
      );

      expect(usuario.ehProfessora, isTrue);
      expect(usuario.ehAluno, isFalse);
    });

    test('identifica perfil aluno', () {
      const usuario = Usuario(
        id: 2,
        nome: 'Ana Clara Almeida',
        email: 'aluna@gmail.com',
        cpf: '55566677788',
        alunoId: 1,
        ativo: true,
      );

      expect(usuario.ehAluno, isTrue);
      expect(usuario.ehProfessora, isFalse);
    });

    test('valida integridade basica do usuario', () {
      const usuario = Usuario(
        id: 1,
        nome: 'Professora',
        email: 'professora@gmail.com',
        cpf: '11122233344',
        professoraId: 1,
        ativo: true,
      );

      expect(usuario.emailValido, isTrue);
      expect(usuario.cpfValido, isTrue);
      expect(usuario.perfilValido, isTrue);
      expect(usuario.valido, isTrue);
    });
  });
}
