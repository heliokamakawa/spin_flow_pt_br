class MusicaCheckin {
  final int musicaId;
  final int posicao;
  final String nome;
  final String nomeArtista;
  final int? avaliacao; // 1–5; null = não avaliada

  const MusicaCheckin({
    required this.musicaId,
    required this.posicao,
    required this.nome,
    required this.nomeArtista,
    this.avaliacao,
  });
}
