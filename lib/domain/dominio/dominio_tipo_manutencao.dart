import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';

class DominioTipoManutencao {
  final TipoManutencao modelo;

  const DominioTipoManutencao(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validar() => validarConsistencia() ?? validarRegras();
}
