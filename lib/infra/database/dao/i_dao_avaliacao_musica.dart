abstract class IDAOAvaliacaoMusica {
  /// Retorna mapa de musicaId → nota para o aluno nas músicas informadas.
  Future<Map<int, int>> buscarAvaliacoesAluno(int alunoId, List<int> musicaIds);

  /// Insere ou atualiza a avaliação do aluno para a música.
  Future<void> salvar(int alunoId, int musicaId, int nota);
}
