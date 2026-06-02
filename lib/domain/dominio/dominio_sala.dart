import 'package:spin_flow/domain/modelo/posicao_bike.dart';
import 'package:spin_flow/domain/modelo/sala.dart';

class DominioSala {
  final Sala modelo;

  const DominioSala(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validarParaSalvar() => validarConsistencia() ?? validarRegras();

  int bikesDisponiveis(
    List<PosicaoBike> posicoes,
    Set<int> bikeIdsEmManutencao,
  ) {
    return posicoes.where((posicao) {
      if (posicao.fila >= modelo.numeroFilas ||
          posicao.coluna >= modelo.numeroColunas) {
        return false;
      }
      if (posicao.fila == modelo.filaProfessora - 1 &&
          posicao.coluna == modelo.colunaProfessora - 1) {
        return false;
      }
      if (posicao.bikeId != null &&
          bikeIdsEmManutencao.contains(posicao.bikeId)) {
        return false;
      }
      return true;
    }).length;
  }

  bool estaLotada(
    int checkinsAtivos,
    List<PosicaoBike> posicoes,
    Set<int> bikeIdsEmManutencao,
  ) =>
      checkinsAtivos >= bikesDisponiveis(posicoes, bikeIdsEmManutencao);
}
