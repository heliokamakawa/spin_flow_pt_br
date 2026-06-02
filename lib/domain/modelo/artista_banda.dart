class ArtistaBanda {
  final int? id;
  final String nome;
  final String descricao;
  final String link;
  final String foto;
  final bool ativo;

  ArtistaBanda({
    this.id,
    required this.nome,
    this.descricao = '',
    this.link = '',
    this.foto = '',
    this.ativo = true,
  });

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    return null;
  }
}
