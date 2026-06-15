class FrequenciaAluno {
  final int alunoId;
  final String nomeAluno;
  final int totalCheckins;
  final int totalAulas;

  const FrequenciaAluno({
    required this.alunoId,
    required this.nomeAluno,
    required this.totalCheckins,
    required this.totalAulas,
  });

  bool get percentualDisponivel => totalAulas > 0;

  double get percentual =>
      percentualDisponivel ? (totalCheckins / totalAulas) * 100 : 0;

  String get percentualTexto =>
      percentualDisponivel ? '${percentual.toStringAsFixed(1)}%' : '—';

  String get textoCheckins =>
      totalAulas > 0 ? '$totalCheckins/$totalAulas' : '$totalCheckins/—';
}