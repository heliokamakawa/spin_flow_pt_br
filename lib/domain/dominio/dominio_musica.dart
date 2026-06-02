import 'package:spin_flow/domain/modelo/musica.dart';

class DominioMusica {
  final Musica modelo;

  const DominioMusica(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validarParaSalvar() => validarConsistencia() ?? validarRegras();
}
