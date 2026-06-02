class Checkin {
  final int? id;
  final int alunoId;
  final int turmaId;
  final DateTime data;
  final int fila; // 0-based
  final int coluna; // 0-based
  final bool ativo;
  final String nomeAluno;

  const Checkin({
    this.id,
    required this.alunoId,
    required this.turmaId,
    required this.data,
    required this.fila,
    required this.coluna,
    this.ativo = true,
    this.nomeAluno = '',
  });

  // ── Invariantes do objeto ──────────────────────────────────────────────────

  bool get posicaoValida => fila >= 0 && coluna >= 0;
  bool get valido => alunoId > 0 && turmaId > 0 && posicaoValida && ativo;

  // ── Regras que o modelo conhece sem precisar de contexto externo ───────────

  bool mesmaData(DateTime outra) =>
      data.year == outra.year &&
      data.month == outra.month &&
      data.day == outra.day;

  bool mesmaPosicao(Checkin outro) =>
      fila == outro.fila && coluna == outro.coluna;

  String? validar() {
    if (alunoId <= 0) return 'Aluno não identificado.';
    if (turmaId <= 0) return 'Turma não identificada.';
    if (fila < 0) return 'Fila inválida.';
    if (coluna < 0) return 'Coluna inválida.';
    return null;
  }
}
