import 'package:spin_flow/domain/modelo/musica_checkin.dart';

class MixCheckin {
  final int mixId;
  final String nomeMix;
  final List<MusicaCheckin> musicas;

  const MixCheckin({
    required this.mixId,
    required this.nomeMix,
    required this.musicas,
  });
}
