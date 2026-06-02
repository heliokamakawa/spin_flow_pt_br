class VideoAula {
  final int? id;
  final String nome;
  final String linkVideo;
  final bool ativo;

  VideoAula({
    this.id,
    required this.nome,
    required this.linkVideo,
    this.ativo = true,
  });

  bool get urlValida =>
      linkVideo.trim().isNotEmpty &&
      (linkVideo.startsWith('http://') || linkVideo.startsWith('https://'));

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (linkVideo.trim().isEmpty) return 'Link do vídeo é obrigatório.';
    if (!urlValida) return 'Link inválido. Use http:// ou https://.';
    return null;
  }
}
