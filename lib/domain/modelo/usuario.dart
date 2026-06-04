import 'package:spin_flow/domain/modelo/cpf.dart';
import 'package:spin_flow/domain/modelo/email.dart';

class Usuario {
  final int id;
  final String nome;
  final String email;
  final String cpf;
  final int? alunoId;
  final int? professoraId;
  final bool ativo;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    this.alunoId,
    this.professoraId,
    required this.ativo,
  });

  bool get ehProfessora => professoraId != null;
  bool get ehAluno => alunoId != null;
  bool get perfilValido => ehProfessora || ehAluno;
  String get perfil {
    if (ehProfessora) return 'professora';
    if (ehAluno) return 'aluno';
    return '';
  }

  bool get cpfValido   => Cpf.valido(cpf);
  bool get emailValido => Email.valido(email);
  bool get valido =>
      id > 0 &&
      nome.isNotEmpty &&
      emailValido &&
      cpfValido &&
      perfilValido &&
      ativo;
}
