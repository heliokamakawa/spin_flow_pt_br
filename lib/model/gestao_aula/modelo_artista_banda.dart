class ModeloArtistaBanda {
  final int? id;
  final String nome;
  final String descricao;
  final String link;
  final String foto;
  final bool ativo;

  ModeloArtistaBanda({
    this.id,
    required this.nome,
    this.descricao = '',
    this.link = '',
    this.foto = '',
    this.ativo = true,
  });
}
