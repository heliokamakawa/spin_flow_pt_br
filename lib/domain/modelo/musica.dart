class Musica {
  final int? id;
  final String nome;
  final String descricao;
  final int? artistaId;
  final String nomeArtista;
  final bool ativo;

  Musica({
    this.id,
    required this.nome,
    this.descricao = '',
    this.artistaId,
    this.nomeArtista = '',
    this.ativo = true,
  });

  String get exibicao => nomeArtista.isEmpty ? nome : '$nome — $nomeArtista';

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (descricao.trim().isEmpty) return 'Descrição é obrigatória.';
    if (artistaId == null) return 'Artista é obrigatório.';
    return null;
  }
}
