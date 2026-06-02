class PosicaoBike {
  final int fila; // 0-based
  final int coluna; // 0-based
  final int? bikeId;
  final String bikeNome;

  const PosicaoBike({
    required this.fila,
    required this.coluna,
    this.bikeId,
    this.bikeNome = '',
  });

  bool get posicaoValida => fila >= 0 && coluna >= 0;
  bool get temBike => bikeId != null;

  // Exibe somente a parte numérica do nome (ex: "Bike 01" → "01", "B03" → "03")
  String get numeroDisplay {
    final nums = bikeNome.replaceAll(RegExp(r'[^0-9]'), '');
    return nums.isEmpty ? bikeNome : nums;
  }
}
