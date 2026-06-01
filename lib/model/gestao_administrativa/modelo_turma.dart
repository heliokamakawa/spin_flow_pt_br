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

class ModeloTurma {
  final int? id;
  final String nome;
  final String horarioInicio;
  final int duracaoMinutos;
  final List<DiaSemana> diasSemana;
  final int salaId;
  final bool ativo;

  const ModeloTurma({
    this.id,
    required this.nome,
    required this.horarioInicio,
    required this.duracaoMinutos,
    required this.diasSemana,
    required this.salaId,
    this.ativo = true,
  });

  bool ocorreEm(DiaSemana dia) => diasSemana.contains(dia);

  bool janelAberta(DateTime agora) {
    final partes = horarioInicio.split(':');
    if (partes.length < 2) return false;
    final h = int.tryParse(partes[0]) ?? 0;
    final m = int.tryParse(partes[1]) ?? 0;
    final inicio = DateTime(agora.year, agora.month, agora.day, h, m);
    return !agora.isBefore(inicio.subtract(const Duration(minutes: 30)));
  }

  String? validar() {
    if (nome.trim().isEmpty) return 'Identificação é obrigatória.';
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(horarioInicio)) {
      return 'Horário de início é obrigatório.';
    }
    if (duracaoMinutos < 1 || duracaoMinutos > 180) {
      return 'Duração deve ser entre 1 e 180 minutos.';
    }
    if (salaId <= 0) return 'Sala é obrigatória.';
    if (diasSemana.isEmpty) return 'Selecione pelo menos um dia da semana.';
    return null;
  }
}
