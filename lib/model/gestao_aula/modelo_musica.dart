class ModeloMusica {
  final int? id;
  final String nome;
  final String descricao;
  final int? artistaId;
  final String nomeArtista;
  final bool ativo;

  ModeloMusica({
    this.id,
    required this.nome,
    this.descricao = '',
    this.artistaId,
    this.nomeArtista = '',
    this.ativo = true,
  });

  String get exibicao => nomeArtista.isEmpty ? nome : '$nome — $nomeArtista';
}
