class Bike {
  final int? id;
  final String nome;
  final String numeroSerie;
  final int fabricanteId;
  final DateTime dataCadastro;
  final bool ativa;

  const Bike({
    this.id,
    required this.nome,
    required this.numeroSerie,
    required this.fabricanteId,
    required this.dataCadastro,
    this.ativa = true,
  });

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (numeroSerie.trim().isEmpty) return 'Número de série é obrigatório.';
    if (fabricanteId <= 0) return 'Fabricante é obrigatório.';
    return null;
  }
}
