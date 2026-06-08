import 'package:spin_flow/domain/modelo/artista_banda.dart';

class DominioArtistaBanda {
  final ArtistaBanda modelo;

  const DominioArtistaBanda(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validar() => validarConsistencia() ?? validarRegras();
}
