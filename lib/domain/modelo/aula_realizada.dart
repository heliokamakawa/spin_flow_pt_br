class AulaRealizada {
  final int? id;
  final int alunoId;
  final int turmaId;
  final DateTime data;
  final bool ativo;

  AulaRealizada({
    this.id,
    required this.alunoId,
    required this.turmaId,
    required this.data,
    this.ativo = true,
  });
}
