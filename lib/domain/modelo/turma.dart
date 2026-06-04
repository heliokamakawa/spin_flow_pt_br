enum DiaSemana {
  segunda('Segunda-feira', 'Seg'),
  terca('Terca-feira', 'Ter'),
  quarta('Quarta-feira', 'Qua'),
  quinta('Quinta-feira', 'Qui'),
  sexta('Sexta-feira', 'Sex'),
  sabado('Sabado', 'Sab'),
  domingo('Domingo', 'Dom');

  final String rotulo;
  final String dbValue;

  const DiaSemana(this.rotulo, this.dbValue);

  static DiaSemana fromDbValue(String valor) {
    return DiaSemana.values.firstWhere(
      (dia) => dia.dbValue == valor,
      orElse: () => DiaSemana.segunda,
    );
  }

  static DiaSemana hoje() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return DiaSemana.segunda;
      case DateTime.tuesday:
        return DiaSemana.terca;
      case DateTime.wednesday:
        return DiaSemana.quarta;
      case DateTime.thursday:
        return DiaSemana.quinta;
      case DateTime.friday:
        return DiaSemana.sexta;
      case DateTime.saturday:
        return DiaSemana.sabado;
      default:
        return DiaSemana.domingo;
    }
  }
}

class Turma {
  final int? id;
  final String nome;
  final String horarioInicio;
  final int duracaoMinutos;
  final List<DiaSemana> diasSemana;
  final int salaId;
  final int? professoraId;
  final int? mixId;
  final bool ativo;

  const Turma({
    this.id,
    required this.nome,
    required this.horarioInicio,
    required this.duracaoMinutos,
    required this.diasSemana,
    required this.salaId,
    this.professoraId,
    this.mixId,
    this.ativo = true,
  });

  bool ocorreEm(DiaSemana dia) => diasSemana.contains(dia);

  DateTime inicioEmData(DateTime data) {
    final partes = horarioInicio.split(':');
    final h = int.tryParse(partes[0]) ?? 0;
    final m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return DateTime(data.year, data.month, data.day, h, m);
  }

  DateTime fimEmData(DateTime data) =>
      inicioEmData(data).add(Duration(minutes: duracaoMinutos));

  bool jaEncerrou(DateTime agora) {
    final data = DateTime(agora.year, agora.month, agora.day);
    return agora.isAfter(fimEmData(data));
  }

  bool janelAberta(DateTime agora) {
    if (jaEncerrou(agora)) return false;
    final data = DateTime(agora.year, agora.month, agora.day);
    return !agora.isBefore(
      inicioEmData(data).subtract(const Duration(minutes: 30)),
    );
  }

  bool sobrepoeHorario(Turma outra, DateTime data) {
    return inicioEmData(data).isBefore(outra.fimEmData(data)) &&
        outra.inicioEmData(data).isBefore(fimEmData(data));
  }

  String? validar() {
    if (nome.trim().isEmpty) return 'Identificação é obrigatória.';
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(horarioInicio)) {
      return 'Horário de início é obrigatório.';
    }
    if (duracaoMinutos < 1 || duracaoMinutos > 100) {
      return 'Duração deve ser entre 1 e 100 minutos.';
    }
    if (salaId <= 0) return 'Sala é obrigatória.';
    if (diasSemana.isEmpty) return 'Selecione pelo menos um dia da semana.';
    return null;
  }
}
