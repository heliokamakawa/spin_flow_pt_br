class Fabricante {
  final int? id;
  final String nome;
  final String descricao;
  final String nomeContatoPrincipal;
  final String emailContato;
  final String telefoneContato;
  final bool ativo;

  const Fabricante({
    this.id,
    required this.nome,
    this.descricao = '',
    this.nomeContatoPrincipal = '',
    this.emailContato = '',
    this.telefoneContato = '',
    this.ativo = true,
  });

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    return null;
  }
}
