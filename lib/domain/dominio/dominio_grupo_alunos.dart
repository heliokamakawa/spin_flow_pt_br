import 'package:spin_flow/domain/modelo/grupo_alunos.dart';

class DominioGrupoAlunos {
  final GrupoAlunos modelo;

  const DominioGrupoAlunos(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validar() => validarConsistencia() ?? validarRegras();
}
