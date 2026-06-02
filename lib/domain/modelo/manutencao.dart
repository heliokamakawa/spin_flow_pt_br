enum EstadoOperacional {
  pendente,
  emAndamento,
  realizado,
  cancelado;

  String get rotulo => switch (this) {
    EstadoOperacional.pendente => 'Pendente',
    EstadoOperacional.emAndamento => 'Em andamento',
    EstadoOperacional.realizado => 'Realizado',
    EstadoOperacional.cancelado => 'Cancelado',
  };

  static EstadoOperacional fromString(String valor) => switch (valor) {
    'em_andamento' => EstadoOperacional.emAndamento,
    'realizado' => EstadoOperacional.realizado,
    'cancelado' => EstadoOperacional.cancelado,
    _ => EstadoOperacional.pendente,
  };

  String get dbValue => switch (this) {
    EstadoOperacional.emAndamento => 'em_andamento',
    _ => name,
  };
}

class Manutencao {
  final int? id;
  final int bikeId;
  final int tipoManutencaoId;
  final DateTime dataSolicitacao;
  final String descricao;
  final EstadoOperacional estadoOperacional;

  const Manutencao({
    this.id,
    required this.bikeId,
    required this.tipoManutencaoId,
    required this.dataSolicitacao,
    required this.descricao,
    this.estadoOperacional = EstadoOperacional.pendente,
  });

  String? validar() {
    if (bikeId <= 0) return 'Bike é obrigatória.';
    if (tipoManutencaoId <= 0) return 'Tipo de manutenção é obrigatório.';
    if (descricao.trim().isEmpty) return 'Descrição é obrigatória.';
    return null;
  }
}
