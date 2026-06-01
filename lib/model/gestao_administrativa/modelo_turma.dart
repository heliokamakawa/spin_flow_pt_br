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
