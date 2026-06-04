class ScriptDinamicasSQLite {
  static List<String> comandosInsercoes(DateTime agora) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final amanha = hoje.add(const Duration(days: 1));

    // Cenario 1: janela ainda nao abriu, pois a aula inicia em 31 minutos.
    final horaAulaFechada = agora.add(const Duration(minutes: 31));
    // Cenario 2: janela aberta, com varios alunos ja confirmados.
    final horaAulaCheckin = agora.add(const Duration(minutes: 15));
    // Cenario 3: janela aberta e todas as posicoes reservaveis preenchidas.
    final horaAulaLotada = agora.add(const Duration(minutes: 10));

    final horarioFechada = _formatarHora(horaAulaFechada);
    final horarioCheckin = _formatarHora(horaAulaCheckin);
    final horarioLotada = _formatarHora(horaAulaLotada);

    final hojeIso = hoje.toIso8601String();
    final ontemIso = ontem.toIso8601String();
    final criadoFila = agora
        .subtract(const Duration(minutes: 5))
        .toIso8601String();

    final diaHoje = _siglaDiaSemana(hoje.weekday);
    final diaAmanha = _siglaDiaSemana(amanha.weekday);

    const nomeTurmaFechada = 'Cadencia Base Hoje';
    const nomeTurmaCheckin = 'Power Ride Check-in Hoje';
    const nomeTurmaLotada = 'Sprint Lotado Hoje';

    return [
      "INSERT INTO turma (nome, horario_inicio, duracao_minutos, sala_id, professora_id, mix_id, ativo) VALUES ('$nomeTurmaFechada', '$horarioFechada', 50, (SELECT id FROM sala WHERE nome = 'Studio Sprint' LIMIT 1), (SELECT professora_id FROM usuario WHERE LOWER(email) = 'professora@gmail.com' LIMIT 1), 4, 1)",
      "INSERT INTO turma (nome, horario_inicio, duracao_minutos, sala_id, professora_id, mix_id, ativo) VALUES ('$nomeTurmaCheckin', '$horarioCheckin', 50, (SELECT id FROM sala WHERE nome = 'Studio Sprint' LIMIT 1), (SELECT professora_id FROM usuario WHERE LOWER(email) = 'marina.torres@pulsestudio.com.br' LIMIT 1), 1, 1)",
      "INSERT INTO turma (nome, horario_inicio, duracao_minutos, sala_id, professora_id, mix_id, ativo) VALUES ('$nomeTurmaLotada', '$horarioLotada', 45, (SELECT id FROM sala WHERE nome = 'Studio Endurance' LIMIT 1), (SELECT professora_id FROM usuario WHERE LOWER(email) = 'professora@gmail.com' LIMIT 1), 2, 1)",

      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaFechada' ORDER BY id DESC LIMIT 1), '$diaHoje')",
      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$diaHoje')",
      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$diaHoje')",
      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$diaAmanha')",

      // Power Ride Check-in Hoje: varios alunos com check-in feito e vagas restantes.
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$ontemIso', 1, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 2, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 3, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 1, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 3, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 4, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 5, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 1, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (11, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 3, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (12, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 4, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (13, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 5, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (14, (SELECT id FROM turma WHERE nome = '$nomeTurmaCheckin' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 0, 1)",

      // Sprint Lotado Hoje: 15 posicoes reservaveis preenchidas.
      // Bikes 2 (0,1) e 9 (1,2) em manutencao ativa — nao recebem check-in.
      // Capacidade efetiva = 17 total - 2 manutencao = 15 reservaveis.
      // aluna@gmail.com (id=1) nao tem check-in aqui e pode entrar na fila.
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (20, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 3, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 4, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 5, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 1, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 3, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 4, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (11, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 5, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (12, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (13, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 1, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (14, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 2, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (15, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 3, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (16, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 4, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (17, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 5, 1)",

      "INSERT INTO fila_espera_checkin (aluno_id, turma_id, data, criado_em, ativo) VALUES (18, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', '$criadoFila', 1)",
      "INSERT INTO fila_espera_checkin (aluno_id, turma_id, data, criado_em, ativo) VALUES (19, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', '${agora.subtract(const Duration(minutes: 3)).toIso8601String()}', 1)",
    ];
  }

  static String _formatarHora(DateTime data) {
    final h = data.hour.toString().padLeft(2, '0');
    final m = data.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _siglaDiaSemana(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sab';
      default:
        return 'Dom';
    }
  }
}
