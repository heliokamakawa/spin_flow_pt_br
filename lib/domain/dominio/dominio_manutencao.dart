import 'package:spin_flow/domain/modelo/manutencao.dart';

class DominioManutencao {
  final Manutencao modelo;

  const DominioManutencao(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validar() => validarConsistencia() ?? validarRegras();
}
