import 'package:flutter_test/flutter_test.dart';
import 'package:spin_flow/model/modelo/modelo_usuario.dart';

void main() {
  group('ModeloUsuario', () {
    test('identifica perfil professora', () {
      const usuario = ModeloUsuario(
        id: 1,
        nome: 'Professora',
        email: 'professora@gmail.com',
        cpf: '11122233344',
        perfil: 'professora',
        ativo: true,
      );

      expect(usuario.ehProfessora, isTrue);
      expect(usuario.ehAluno, isFalse);
    });

    test('identifica perfil aluno', () {
      const usuario = ModeloUsuario(
        id: 2,
        nome: 'Aluno',
        email: 'aluno@gmail.com',
        cpf: '55566677788',
        perfil: 'aluno',
        ativo: true,
      );

      expect(usuario.ehAluno, isTrue);
      expect(usuario.ehProfessora, isFalse);
    });

    test('valida integridade basica do usuario', () {
      const usuario = ModeloUsuario(
        id: 1,
        nome: 'Professora',
        email: 'professora@gmail.com',
        cpf: '11122233344',
        perfil: 'professora',
        ativo: true,
      );

      expect(usuario.emailValido, isTrue);
      expect(usuario.cpfValido, isTrue);
      expect(usuario.perfilValido, isTrue);
      expect(usuario.valido, isTrue);
    });
  });
}
