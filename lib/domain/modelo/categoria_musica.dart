class CategoriaMusica {
  final int? id;
  final String nome;
  final String descricao;
  final bool ativa;

  CategoriaMusica({
    this.id,
    required this.nome,
    this.descricao = '',
    this.ativa = true,
  });

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    return null;
  }
}
