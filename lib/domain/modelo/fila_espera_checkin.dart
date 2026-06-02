class FilaEsperaCheckin {
  final int? id;
  final int alunoId;
  final int turmaId;
  final DateTime data;
  final DateTime criadoEm;
  final bool ativo;

  const FilaEsperaCheckin({
    this.id,
    required this.alunoId,
    required this.turmaId,
    required this.data,
    required this.criadoEm,
    this.ativo = true,
  });

  bool get valido => alunoId > 0 && turmaId > 0 && ativo;
}
