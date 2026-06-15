import 'package:spin_flow/domain/modelo/video_aula.dart';

class MusicaRepertorioProfessora {
  final int musicaId;
  final int posicao;
  final String nome;
  final String nomeArtista;
  final double? mediaAvaliacao;
  final int totalAvaliadores;
  final List<VideoAula> videos;

  const MusicaRepertorioProfessora({
    required this.musicaId,
    required this.posicao,
    required this.nome,
    required this.nomeArtista,
    this.mediaAvaliacao,
    this.totalAvaliadores = 0,
    this.videos = const [],
  });
}
