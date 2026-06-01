class ModeloVideoAula {
  final int? id;
  final String nome;
  final String linkVideo;
  final bool ativo;

  ModeloVideoAula({
    this.id,
    required this.nome,
    required this.linkVideo,
    this.ativo = true,
  });
}
