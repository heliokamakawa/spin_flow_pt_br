import 'package:spin_flow/domain/modelo/checkin.dart';

class DominioCheckin {
  final Checkin modelo;

  const DominioCheckin(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validarParaSalvar() => validarConsistencia() ?? validarRegras();
}
