class MusicaRepertorioProfessora {
  final int musicaId;
  final int posicao;
  final String nome;
  final String nomeArtista;
  final double? mediaAvaliacao; // null = nenhuma avaliação ainda
  final int totalAvaliadores;

  const MusicaRepertorioProfessora({
    required this.musicaId,
    required this.posicao,
    required this.nome,
    required this.nomeArtista,
    this.mediaAvaliacao,
    this.totalAvaliadores = 0,
  });
}
