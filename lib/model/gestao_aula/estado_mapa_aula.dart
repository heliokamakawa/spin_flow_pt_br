import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/model/gestao_aula/modelo_checkin.dart';
import 'package:spin_flow/model/gestao_aula/modelo_posicao_bike.dart';

class EstadoMapaAula {
  final ModeloTurma turma;
  final ModeloSala sala;
  final List<ModeloPosicaoBike> posicoes;
  final List<ModeloCheckin> checkinsAtivos;
  final Set<int> bikeIdsEmManutencao;

  const EstadoMapaAula({
    required this.turma,
    required this.sala,
    required this.posicoes,
    required this.checkinsAtivos,
    required this.bikeIdsEmManutencao,
  });

  ModeloPosicaoBike? posicaoEm(int fila, int coluna) {
    for (final p in posicoes) {
      if (p.fila == fila && p.coluna == coluna) return p;
    }
    return null;
  }

  ModeloCheckin? checkinEm(int fila, int coluna) {
    for (final c in checkinsAtivos) {
      if (c.fila == fila && c.coluna == coluna) return c;
    }
    return null;
  }

  bool ehProfessora(int fila, int coluna) =>
      fila == sala.filaProfessora - 1 && coluna == sala.colunaProfessora - 1;

  bool emManutencao(int fila, int coluna) {
    final p = posicaoEm(fila, coluna);
    return p?.bikeId != null && bikeIdsEmManutencao.contains(p!.bikeId);
  }

  int get totalBikes =>
      sala.bikesDisponiveis(posicoes, bikeIdsEmManutencao);

  bool get lotada => checkinsAtivos.length >= totalBikes;
}

class ResumoTurmaHoje {
  final ModeloTurma turma;
  final String nomeSala;

  const ResumoTurmaHoje({required this.turma, required this.nomeSala});
}

class ResumoTurmaCheckin {
  final ModeloTurma turma;
  final String nomeSala;
  final int totalBikes;
  final int vagasDisponiveis;
  final bool janelAberta;
  final bool alunoJaTemCheckin;
  final int? posicaoNaFila; // 1-based; null = nao esta na fila

  const ResumoTurmaCheckin({
    required this.turma,
    required this.nomeSala,
    required this.totalBikes,
    required this.vagasDisponiveis,
    required this.janelAberta,
    required this.alunoJaTemCheckin,
    this.posicaoNaFila,
  });

  bool get lotada => vagasDisponiveis == 0;
  bool get alunoNaFila => posicaoNaFila != null;
}

class MapaCheckinAluno {
  final EstadoMapaAula mapa;
  final int alunoId;
  final bool janelAberta;
  final int? idCheckinDoAluno; // para cancelar a propria reserva
  final int? posicaoNaFila; // posicao 1-based na fila de espera
  final int? filaId; // id do registro na fila (para sair)

  const MapaCheckinAluno({
    required this.mapa,
    required this.alunoId,
    required this.janelAberta,
    this.idCheckinDoAluno,
    this.posicaoNaFila,
    this.filaId,
  });

  bool get lotada => mapa.lotada;
}
