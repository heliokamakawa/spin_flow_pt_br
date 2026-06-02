import 'package:spin_flow/domain/modelo/turma.dart';

class DominioTurma {
  final Turma modelo;

  const DominioTurma(this.modelo);

  String? validarConsistencia() => modelo.validar();

  String? validarRegras() => null;

  String? validarParaSalvar() => validarConsistencia() ?? validarRegras();

  bool ocorreEm(DiaSemana dia) => modelo.diasSemana.contains(dia);

  DateTime inicioEmData(DateTime data) {
    final partes = modelo.horarioInicio.split(':');
    final hora = int.tryParse(partes[0]) ?? 0;
    final minuto = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return DateTime(data.year, data.month, data.day, hora, minuto);
  }

  DateTime fimEmData(DateTime data) =>
      inicioEmData(data).add(Duration(minutes: modelo.duracaoMinutos));

  bool jaEncerrou(DateTime agora) {
    final data = DateTime(agora.year, agora.month, agora.day);
    return agora.isAfter(fimEmData(data));
  }

  bool janelaAberta(DateTime agora) {
    if (jaEncerrou(agora)) return false;
    final data = DateTime(agora.year, agora.month, agora.day);
    return !agora.isBefore(
      inicioEmData(data).subtract(const Duration(minutes: 30)),
    );
  }

  bool sobrepoeHorario(Turma outra, DateTime data) {
    final dominioOutra = DominioTurma(outra);
    return inicioEmData(data).isBefore(dominioOutra.fimEmData(data)) &&
        dominioOutra.inicioEmData(data).isBefore(fimEmData(data));
  }
}
