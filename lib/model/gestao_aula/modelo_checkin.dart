class ModeloCheckin {
  final int? id;
  final int alunoId;
  final int turmaId;
  final DateTime data;
  final int fila; // 0-based
  final int coluna; // 0-based
  final bool ativo;
  final String nomeAluno;

  const ModeloCheckin({
    this.id,
    required this.alunoId,
    required this.turmaId,
    required this.data,
    required this.fila,
    required this.coluna,
    this.ativo = true,
    this.nomeAluno = '',
  });
}
