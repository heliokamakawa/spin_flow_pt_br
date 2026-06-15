class TipoManutencao {
  final int? id;
  final String nome;
  final String descricao;
  final bool ativa;

  const TipoManutencao({
    this.id,
    required this.nome,
    this.descricao = '',
    this.ativa = true,
  });

  TipoManutencao copyWith({
    int? id,
    String? nome,
    String? descricao,
    bool? ativa,
  }) {
    return TipoManutencao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ativa: ativa ?? this.ativa,
    );
  }

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    return null;
  }
}
