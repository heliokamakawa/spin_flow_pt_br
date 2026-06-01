class ModeloCategoriaMusica {
  final int? id;
  final String nome;
  final String descricao;
  final bool ativa;

  ModeloCategoriaMusica({
    this.id,
    required this.nome,
    this.descricao = '',
    this.ativa = true,
  });
}
