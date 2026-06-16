/// Nível de engajamento do aluno, determinado pela quantidade de semanas
/// seguidas (consecutivas) com pelo menos uma aula realizada.
///
/// Regra: Prata a partir de 1 semana, Ouro a partir de 3, Diamante a partir
/// de 5. Abaixo de 1 semana o aluno ainda não possui nível (`nenhum`).
enum NivelAluno {
  nenhum(0, 'Iniciante'),
  prata(1, 'Prata'),
  ouro(3, 'Ouro'),
  diamante(5, 'Diamante');

  /// Mínimo de semanas seguidas para alcançar o nível.
  final int semanasMinimas;
  final String rotulo;

  const NivelAluno(this.semanasMinimas, this.rotulo);

  /// Determina o nível a partir das semanas seguidas.
  static NivelAluno fromSemanasSeguidas(int semanas) {
    if (semanas >= NivelAluno.diamante.semanasMinimas) return NivelAluno.diamante;
    if (semanas >= NivelAluno.ouro.semanasMinimas) return NivelAluno.ouro;
    if (semanas >= NivelAluno.prata.semanasMinimas) return NivelAluno.prata;
    return NivelAluno.nenhum;
  }

  /// Os três níveis exibidos na timeline (exclui `nenhum`).
  static const List<NivelAluno> niveisTimeline = [
    NivelAluno.prata,
    NivelAluno.ouro,
    NivelAluno.diamante,
  ];
}
