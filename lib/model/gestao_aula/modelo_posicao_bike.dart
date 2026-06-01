class ModeloPosicaoBike {
  final int fila; // 0-based
  final int coluna; // 0-based
  final int? bikeId;
  final String bikeNome;

  const ModeloPosicaoBike({
    required this.fila,
    required this.coluna,
    this.bikeId,
    this.bikeNome = '',
  });
}
