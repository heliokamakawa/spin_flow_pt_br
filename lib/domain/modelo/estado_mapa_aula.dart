import 'sala.dart';
import 'package:spin_flow/domain/dominio/dominio_sala.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/turma.dart';
import 'package:spin_flow/domain/modelo/checkin.dart';
import 'package:spin_flow/domain/modelo/posicao_bike.dart';

class EstadoMapaAula {
  final Turma turma;
  final Sala sala;
  final List<PosicaoBike> posicoes;
  final List<Checkin> checkinsAtivos;
  final Set<int> bikeIdsEmManutencao;
  // bikeId → descricao da manutencao ativa
  final Map<int, String> motivosManutencao;

  const EstadoMapaAula({
    required this.turma,
    required this.sala,
    required this.posicoes,
    required this.checkinsAtivos,
    required this.bikeIdsEmManutencao,
    this.motivosManutencao = const {},
  });

  PosicaoBike? posicaoEm(int fila, int coluna) {
    for (final p in posicoes) {
      if (p.fila == fila && p.coluna == coluna) return p;
    }
    return null;
  }

  Checkin? checkinEm(int fila, int coluna) {
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

  // Vagas reserváveis = não-professora, não-manutenção
  int get totalBikes =>
      DominioSala(sala).bikesDisponiveis(posicoes, bikeIdsEmManutencao);

  // Bikes presentes mas em manutenção ativa (informativo para o aluno)
  int get bikesEmManutencao =>
      DominioSala(sala).bikesDisponiveis(posicoes, const {}) - totalBikes;

  bool get lotada => checkinsAtivos.length >= totalBikes;

  String? motivoManutencaoEm(int fila, int coluna) {
    final p = posicaoEm(fila, coluna);
    if (p?.bikeId == null) return null;
    return motivosManutencao[p!.bikeId!];
  }

  bool bikeDisponivelParaCheckin(int fila, int coluna) {
    if (ehProfessora(fila, coluna)) return false;
    final p = posicaoEm(fila, coluna);
    if (p == null) return false;
    if (emManutencao(fila, coluna)) return false;
    if (checkinEm(fila, coluna) != null) return false;
    return true;
  }
}

class ResumoTurmaHoje {
  final Turma turma;
  final String nomeSala;

  const ResumoTurmaHoje({required this.turma, required this.nomeSala});
}

class ResumoTurmaCheckin {
  final Turma turma;
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
  final int? idCheckinDoAluno;
  final int? posicaoNaFila;
  final int? filaId;
  final String? nomeProfessora;
  final MixCheckin? mix;

  const MapaCheckinAluno({
    required this.mapa,
    required this.alunoId,
    required this.janelAberta,
    this.idCheckinDoAluno,
    this.posicaoNaFila,
    this.filaId,
    this.nomeProfessora,
    this.mix,
  });

  bool get lotada => mapa.lotada;
}
