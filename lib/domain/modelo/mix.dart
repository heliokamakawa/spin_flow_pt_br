class Mix {
  static const int totalSlots = 10;

  final int? id;
  final String nome;
  final String descricao;
  final List<int?> posicoes; // tamanho fixo = totalSlots; null = slot vazio
  final bool ativo;

  Mix({
    this.id,
    required this.nome,
    this.descricao = '',
    List<int?> posicoes = const [],
    this.ativo = true,
  }) : posicoes = _normalizar(posicoes);

  static List<int?> _normalizar(List<int?> entrada) {
    final lista = List<int?>.from(entrada);
    while (lista.length < totalSlots) {
      lista.add(null);
    }
    return lista.sublist(0, totalSlots);
  }

  int get musicasPreenchidas => posicoes.whereType<int>().length;
  bool get temVaga => musicasPreenchidas < totalSlots;

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (musicasPreenchidas == 0) return 'Adicione pelo menos uma música ao mix.';
    return null;
  }
}
