class ModeloFilaEsperaCheckin {
  final int? id;
  final int alunoId;
  final int turmaId;
  final DateTime data;
  final DateTime criadoEm;
  final bool ativo;

  const ModeloFilaEsperaCheckin({
    this.id,
    required this.alunoId,
    required this.turmaId,
    required this.data,
    required this.criadoEm,
    this.ativo = true,
  });
}
