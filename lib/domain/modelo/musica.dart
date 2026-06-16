class Musica {
  final int? id;
  final String nome;
  final String descricao;
  final int? artistaId;
  final String nomeArtista;
  final bool ativo;
  final double? mediaEstrelas;

  Musica({
    this.id,
    required this.nome,
    this.descricao = '',
    this.artistaId,
    this.nomeArtista = '',
    this.ativo = true,
    this.mediaEstrelas,
  });

  String get exibicao => nomeArtista.isEmpty ? nome : '$nome — $nomeArtista';

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (artistaId == null) return 'Artista é obrigatório.';
    return null;
  }
}
