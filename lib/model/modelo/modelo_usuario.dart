class ModeloUsuario {
  final int id;
  final String nome;
  final String email;
  final String cpf;
  final String perfil;
  final bool ativo;

  const ModeloUsuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.perfil,
    required this.ativo,
  });

  bool get ehProfessora => perfil.toLowerCase() == 'professora';
  bool get ehAluno => perfil.toLowerCase() == 'aluno';
  bool get perfilValido => ehProfessora || ehAluno;
  bool get cpfValido => RegExp(r'^\d{11}$').hasMatch(cpf);
  bool get emailValido => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  bool get valido =>
      id > 0 &&
      nome.isNotEmpty &&
      emailValido &&
      cpfValido &&
      perfilValido &&
      ativo;
}
