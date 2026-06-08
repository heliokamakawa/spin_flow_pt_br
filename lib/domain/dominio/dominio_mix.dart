import 'package:spin_flow/domain/modelo/mix.dart';

class DominioMix {
  final Mix modelo;

  const DominioMix(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validar() => validarConsistencia() ?? validarRegras();
}
