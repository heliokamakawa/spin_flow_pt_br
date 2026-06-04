import 'package:spin_flow/domain/modelo/musica_repertorio_professora.dart';

class MixRepertorioProfessora {
  final int mixId;
  final String nomeMix;
  final List<MusicaRepertorioProfessora> musicas;

  const MixRepertorioProfessora({
    required this.mixId,
    required this.nomeMix,
    required this.musicas,
  });
}
