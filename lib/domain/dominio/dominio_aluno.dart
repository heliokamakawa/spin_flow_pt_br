import 'package:spin_flow/domain/modelo/aluno.dart';

class DominioAluno {
  final Aluno modelo;

  const DominioAluno(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validarParaSalvar() => validarConsistencia() ?? validarRegras();
}
