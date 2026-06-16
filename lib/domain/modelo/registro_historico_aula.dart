/// Representa uma aula no histórico de participação do aluno.
///
/// Hoje a base de dados registra apenas presenças (`aula_realizada.ativo = 1`),
/// portanto [presente] é sempre `true`. O campo é mantido para permitir a
/// distinção Presente/Falta caso a regra evolua no futuro.
class RegistroHistoricoAula {
  final String nomeTurma;
  final DateTime data;
  final String horarioInicio;
  final bool presente;

  const RegistroHistoricoAula({
    required this.nomeTurma,
    required this.data,
    required this.horarioInicio,
    this.presente = true,
  });

  String get rotuloStatus => presente ? 'Presente' : 'Falta';
}
