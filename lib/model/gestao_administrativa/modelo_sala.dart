import 'package:spin_flow/model/gestao_aula/modelo_posicao_bike.dart';

class ModeloSala {
  final int? id;
  final String nome;
  final int numeroFilas;
  final int numeroColunas;
  final int filaProfessora;
  final int colunaProfessora;
  final bool ativa;

  const ModeloSala({
    this.id,
    required this.nome,
    required this.numeroFilas,
    required this.numeroColunas,
    required this.filaProfessora,
    required this.colunaProfessora,
    this.ativa = true,
  });

  int get capacidade => numeroFilas * numeroColunas;

  int get posicaoProfessora =>
      (filaProfessora - 1) * numeroColunas + colunaProfessora;

  bool get posicaoProfessoraValida =>
      filaProfessora >= 1 &&
      filaProfessora <= numeroFilas &&
      colunaProfessora >= 1 &&
      colunaProfessora <= numeroColunas;

  int bikesDisponiveis(
    List<ModeloPosicaoBike> posicoes,
    Set<int> bikeIdsEmManutencao,
  ) {
    return posicoes.where((p) {
      if (p.fila >= numeroFilas || p.coluna >= numeroColunas) return false;
      if (p.fila == filaProfessora - 1 && p.coluna == colunaProfessora - 1) {
        return false;
      }
      if (p.bikeId != null && bikeIdsEmManutencao.contains(p.bikeId)) {
        return false;
      }
      return true;
    }).length;
  }

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (numeroFilas < 1 || numeroFilas > 6) {
      return 'Número de filas deve ser entre 1 e 6.';
    }
    if (numeroColunas < 1 || numeroColunas > 10) {
      return 'Número de colunas deve ser entre 1 e 10.';
    }
    if (!posicaoProfessoraValida) return 'Posição da professora fora da grade.';
    return null;
  }
}
