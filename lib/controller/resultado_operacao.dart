class ResultadoOperacao {
  final bool sucesso;
  final String? mensagemErro;

  const ResultadoOperacao._({required this.sucesso, this.mensagemErro});

  const ResultadoOperacao.sucesso() : this._(sucesso: true);

  const ResultadoOperacao.falha({required String mensagemErro})
    : this._(sucesso: false, mensagemErro: mensagemErro);
}
