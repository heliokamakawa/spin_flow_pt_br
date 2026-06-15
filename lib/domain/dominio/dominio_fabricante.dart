import 'package:spin_flow/domain/modelo/fabricante.dart';

class DominioFabricante {
  final Fabricante modelo;

  const DominioFabricante(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validar() => validarConsistencia() ?? validarRegras();
}
