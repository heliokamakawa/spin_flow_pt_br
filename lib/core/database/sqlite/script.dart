class ScriptSQLite {
  static const String _criarTabelaFabricante = '''
    CREATE TABLE fabricante (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT,
      nome_contato_principal TEXT,
      email_contato TEXT,
      telefone_contato TEXT,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaCategoriaMusica = '''
    CREATE TABLE categoria_musica (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT,
      ativa INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaTipoManutencao = '''
    CREATE TABLE tipo_manutencao (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT,
      ativa INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaArtistaBanda = '''
    CREATE TABLE artista_banda (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT,
      link TEXT,
      foto TEXT,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaAluno = '''
    CREATE TABLE aluno (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      email TEXT NOT NULL,
      data_nascimento TEXT NOT NULL,
      genero TEXT NOT NULL,
      telefone TEXT NOT NULL,
      url_foto TEXT,
      instagram TEXT,
      facebook TEXT,
      tiktok TEXT,
      observacoes TEXT,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaSala = '''
    CREATE TABLE sala (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      numero_filas INTEGER NOT NULL,
      numero_colunas INTEGER NOT NULL,
      posicao_professora INTEGER NOT NULL,
      ativa INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaBike = '''
    CREATE TABLE bike (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      numero_serie TEXT NOT NULL,
      fabricante_id INTEGER,
      data_cadastro TEXT NOT NULL,
      ativa INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaVideoAula = '''
    CREATE TABLE video_aula (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      link_video TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaUsuario = '''
    CREATE TABLE usuario (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      cpf TEXT NOT NULL UNIQUE,
      senha TEXT NOT NULL,
      perfil TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaMusica = '''
    CREATE TABLE musica (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      artista_id INTEGER,
      categoria_ids TEXT,
      video_aula_ids TEXT,
      descricao TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaMix = '''
    CREATE TABLE mix (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      musica_ids TEXT,
      descricao TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaMusicaCategoria = '''
    CREATE TABLE musica_categoria (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      musica_id INTEGER NOT NULL,
      categoria_id INTEGER NOT NULL,
      UNIQUE(musica_id, categoria_id)
    )
  ''';

  static const String _criarTabelaMusicaVideoAula = '''
    CREATE TABLE musica_video_aula (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      musica_id INTEGER NOT NULL,
      video_aula_id INTEGER NOT NULL,
      UNIQUE(musica_id, video_aula_id)
    )
  ''';

  static const String _criarTabelaMixMusica = '''
    CREATE TABLE mix_musica (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mix_id INTEGER NOT NULL,
      musica_id INTEGER NOT NULL,
      posicao INTEGER NOT NULL,
      UNIQUE(mix_id, posicao)
    )
  ''';

  static const String criarTabelaMixMusicaSeNaoExistir = '''
    CREATE TABLE IF NOT EXISTS mix_musica (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mix_id INTEGER NOT NULL,
      musica_id INTEGER NOT NULL,
      posicao INTEGER NOT NULL,
      UNIQUE(mix_id, posicao)
    )
  ''';

  static const String _criarTabelaAvaliacaoMusica = '''
    CREATE TABLE avaliacao_musica (
      aluno_id INTEGER NOT NULL,
      musica_id INTEGER NOT NULL,
      nota INTEGER NOT NULL CHECK(nota BETWEEN 1 AND 5),
      atualizado_em TEXT NOT NULL,
      PRIMARY KEY(aluno_id, musica_id)
    )
  ''';

  static const String criarTabelaAvaliacaoMusicaSeNaoExistir = '''
    CREATE TABLE IF NOT EXISTS avaliacao_musica (
      aluno_id INTEGER NOT NULL,
      musica_id INTEGER NOT NULL,
      nota INTEGER NOT NULL CHECK(nota BETWEEN 1 AND 5),
      atualizado_em TEXT NOT NULL,
      PRIMARY KEY(aluno_id, musica_id)
    )
  ''';

  static const String _criarTabelaTurma = '''
    CREATE TABLE turma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT NOT NULL,
      dias_semana TEXT NOT NULL,
      horario_inicio TEXT NOT NULL,
      duracao_minutos INTEGER NOT NULL,
      sala_id INTEGER,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaTurmaDiaSemana = '''
    CREATE TABLE turma_dia_semana (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      turma_id INTEGER NOT NULL,
      dia_semana TEXT NOT NULL,
      UNIQUE(turma_id, dia_semana)
    )
  ''';

  static const String _criarTabelaGrupoAlunos = '''
    CREATE TABLE grupo_alunos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT NOT NULL,
      aluno_ids TEXT,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaGrupoAluno = '''
    CREATE TABLE grupo_aluno (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      grupo_alunos_id INTEGER NOT NULL,
      aluno_id INTEGER NOT NULL,
      UNIQUE(grupo_alunos_id, aluno_id)
    )
  ''';

  static const String _criarTabelaManutencao = '''
    CREATE TABLE manutencao (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bike_id INTEGER,
      tipo_manutencao_id INTEGER,
      data_solicitacao TEXT NOT NULL,
      data_realizacao TEXT,
      descricao TEXT NOT NULL,
      estado_operacional TEXT NOT NULL DEFAULT 'pendente',
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaCheckin = '''
    CREATE TABLE checkin (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      aluno_id INTEGER,
      turma_id INTEGER,
      data TEXT NOT NULL,
      fila INTEGER NOT NULL,
      coluna INTEGER NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaFilaEsperaCheckin = '''
    CREATE TABLE fila_espera_checkin (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      aluno_id INTEGER NOT NULL,
      turma_id INTEGER NOT NULL,
      data TEXT NOT NULL,
      criado_em TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaTurmaMix = '''
    CREATE TABLE turma_mix (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      turma_id INTEGER,
      mix_id INTEGER,
      data_inicio TEXT NOT NULL,
      data_fim TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaPosicaoBike = '''
    CREATE TABLE posicao_bike (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fila INTEGER NOT NULL,
      coluna INTEGER NOT NULL,
      bike_id INTEGER
    )
  ''';

  static const List<String> comandosCriarTabelas = [
    _criarTabelaFabricante,
    _criarTabelaCategoriaMusica,
    _criarTabelaTipoManutencao,
    _criarTabelaArtistaBanda,
    _criarTabelaAluno,
    _criarTabelaUsuario,
    _criarTabelaSala,
    _criarTabelaBike,
    _criarTabelaVideoAula,
    _criarTabelaMusica,
    _criarTabelaMusicaCategoria,
    _criarTabelaMusicaVideoAula,
    _criarTabelaMix,
    _criarTabelaMixMusica,
    _criarTabelaAvaliacaoMusica,
    _criarTabelaTurma,
    _criarTabelaTurmaDiaSemana,
    _criarTabelaGrupoAlunos,
    _criarTabelaGrupoAluno,
    _criarTabelaManutencao,
    _criarTabelaCheckin,
    _criarTabelaFilaEsperaCheckin,
    _criarTabelaTurmaMix,
    _criarTabelaPosicaoBike,
  ];

  static const List<String> _insercoesFabricante = [
    "INSERT INTO fabricante (nome, descricao, nome_contato_principal, email_contato, telefone_contato, ativo) VALUES ('Technogym', 'Fabricante italiano premium, referencia mundial em equipamentos fitness e indoor cycling', 'Marco Rossi', 'contato@technogym.com.br', '(11) 3030-4040', 1)",
    "INSERT INTO fabricante (nome, descricao, nome_contato_principal, email_contato, telefone_contato, ativo) VALUES ('Movement', 'Fabricante brasileiro com forte presenca em estudios de indoor cycling no Brasil', 'Ana Paula Mendes', 'vendas@movement.com.br', '(19) 3456-7890', 1)",
    "INSERT INTO fabricante (nome, descricao, nome_contato_principal, email_contato, telefone_contato, ativo) VALUES ('Schwinn Fitness', 'Marca americana classica, pioneira nas bikes de spinning com modelos IC Series', 'Carlos Duarte', 'suporte@schwinn.com.br', '(11) 4002-8922', 1)",
    "INSERT INTO fabricante (nome, descricao, nome_contato_principal, email_contato, telefone_contato, ativo) VALUES ('Keiser', 'Fabricante americano conhecido pela M3 Plus, referencia em resistencia magnetica', 'Julia Santos', 'julia.santos@keiser.com.br', '(21) 3500-1200', 1)",
    "INSERT INTO fabricante (nome, descricao, nome_contato_principal, email_contato, telefone_contato, ativo) VALUES ('Stages Cycling', 'Marca americana especializada em bikes de alta performance com medidor de potencia integrado', 'Roberto Lima', 'roberto@stagescycling.com.br', '(11) 9876-5432', 1)",
  ];

  static const List<String> _insercoesCategoriaMusica = [
    "INSERT INTO categoria_musica (nome, ativa) VALUES ('Cadencia', 1)",
    "INSERT INTO categoria_musica (nome, ativa) VALUES ('Ritmo', 1)",
    "INSERT INTO categoria_musica (nome, ativa) VALUES ('Forca', 1)",
    "INSERT INTO categoria_musica (nome, ativa) VALUES ('Relaxamento', 1)",
    "INSERT INTO categoria_musica (nome, ativa) VALUES ('Aquecimento', 1)",
  ];

  static const List<String> _insercoesTipoManutencao = [
    "INSERT INTO tipo_manutencao (nome, descricao, ativa) VALUES ('Pedal quebrado', 'Pedal danificado, com rosca gasta ou solto do eixo', 1)",
    "INSERT INTO tipo_manutencao (nome, descricao, ativa) VALUES ('Regulagem de altura', 'Banco ou guidao fora do padrao, trava de ajuste com defeito', 1)",
    "INSERT INTO tipo_manutencao (nome, descricao, ativa) VALUES ('Banco com problema', 'Banco trincado, frouxo ou com espuma danificada', 1)",
    "INSERT INTO tipo_manutencao (nome, descricao, ativa) VALUES ('Correia de transmissao', 'Correia desgastada, estufada ou com ruido durante o pedal', 1)",
    "INSERT INTO tipo_manutencao (nome, descricao, ativa) VALUES ('Resistencia com defeito', 'Mecanismo de resistencia travado, sem resposta ou com variacao irregular', 1)",
  ];

  static const List<String> _insercoesArtistaBanda = [
    "INSERT INTO artista_banda (nome, descricao, link, foto, ativo) VALUES ('The Weeknd', 'R&B', 'https://theweeknd.com', 'https://example.com/theweeknd.jpg', 1)",
    "INSERT INTO artista_banda (nome, descricao, link, foto, ativo) VALUES ('Dua Lipa', 'Pop', 'https://dualipa.com', 'https://example.com/dualipa.jpg', 1)",
    "INSERT INTO artista_banda (nome, descricao, link, foto, ativo) VALUES ('Imagine Dragons', 'Rock', 'https://imaginedragonsmusic.com', 'https://example.com/imaginedragons.jpg', 1)",
  ];

  static const List<String> _insercoesAluno = [
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Carlos Almeida', 'aluno@gmail.com', '1990-05-15', 'masculino', '(11) 99999-1101', '', '', '', '', 'Uso intenso: aluno de alta frequencia, treina spinning de 4 a 5 vezes por semana e costuma reservar primeira fileira', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Fernanda Lima', 'fernanda.lima@email.com', '1995-07-08', 'feminino', '(11) 99999-1102', '', '', '', '', 'Uso intenso: alta frequencia nas turmas da noite e preferencia por aulas de endurance', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Roberto Gomes', 'roberto.gomes@email.com', '1991-09-14', 'masculino', '(11) 99999-1103', '', '', '', '', 'Uso intenso: participa de treinos de sprint e acompanha indicadores de evolucao', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Juliana Martins', 'juliana.martins@email.com', '1994-06-03', 'feminino', '(11) 99999-1104', '', '', '', '', 'Uso intenso: aluna recorrente nas aulas da manha e costuma avaliar repertorios', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Patricia Souza', 'patricia.souza@email.com', '1987-01-25', 'feminino', '(11) 99999-1105', '', '', '', '', 'Uso intenso: treina em turmas avancadas e alterna bikes centrais', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Lucas Oliveira', 'lucas.oliveira@email.com', '1993-11-30', 'masculino', '(11) 99999-1106', '', '', '', '', 'Uso intenso: preferencia por aulas de subida e resistencia no fim do dia', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Mariana Costa', 'mariana.costa@email.com', '1992-12-10', 'feminino', '(11) 99999-1107', '', '', '', '', 'Uso intenso: frequenta quatro aulas por semana e prioriza bikes da lateral direita', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Diego Matos', 'diego.matos@email.com', '1989-02-19', 'masculino', '(11) 99999-1108', '', '', '', '', 'Uso intenso: foco em condicionamento cardiovascular e aulas HIIT', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Camila Teixeira', 'camila.teixeira@email.com', '1996-10-21', 'feminino', '(11) 99999-1109', '', '', '', '', 'Uso intenso: aluna assidua em rhythm ride e sprints curtos', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Rafael Monteiro', 'rafael.monteiro@email.com', '1986-04-12', 'masculino', '(11) 99999-1110', '', '', '', '', 'Uso intenso: participa de desafios internos e acompanha historico semanal', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Joao Santos', 'joao.santos@email.com', '1985-08-22', 'masculino', '(11) 99999-1111', '', '', '', '', 'Iniciante: em adaptacao ao spinning, prefere aulas de tecnica e baixa intensidade', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Bruna Andrade', 'bruna.andrade@email.com', '1998-01-18', 'feminino', '(11) 99999-1112', '', '', '', '', 'Iniciante: primeiras semanas de treino, orientada a usar bikes de facil acesso', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Elaine Cardoso', 'elaine.cardoso@email.com', '1997-05-27', 'feminino', '(11) 99999-1113', '', '', '', '', 'Iniciante: retorno gradual aos treinos e acompanhamento de carga moderada', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Igor Pacheco', 'igor.pacheco@email.com', '1990-08-09', 'masculino', '(11) 99999-1114', '', '', '', '', 'Iniciante: foco em aprender cadencia e ajuste correto da bike', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Larissa Melo', 'larissa.melo@email.com', '1999-03-16', 'feminino', '(11) 99999-1115', '', '', '', '', 'Iniciante: prefere aulas de base e acompanhamento proximo da professora', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Maria Costa', 'maria.costa@email.com', '1992-07-11', 'feminino', '(11) 99999-1116', '', '', '', '', 'Mediano: participa duas vezes por semana e alterna entre ritmo e subida', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Carlos Pereira', 'carlos.pereira@email.com', '1988-03-20', 'masculino', '(11) 99999-1117', '', '', '', '', 'Mediano: frequencia regular, bom desempenho em aulas de resistencia', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Ana Ribeiro', 'ana.ribeiro@email.com', '1991-06-24', 'feminino', '(11) 99999-1118', '', '', '', '', 'Mediano: prefere turmas no almoco e ritmos constantes', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Pedro Lima', 'pedro.lima@email.com', '1984-12-02', 'masculino', '(11) 99999-1119', '', '', '', '', 'Mediano: participa de treinos funcionais e spinning em dias alternados', 1)",
    "INSERT INTO aluno (nome, email, data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('Sabrina Duarte', 'sabrina.duarte@email.com', '1993-09-05', 'feminino', '(11) 99999-1120', '', '', '', '', 'Mediano: boa adaptacao a sprint, ainda evoluindo em aulas longas', 1)",
  ];

  static const List<String> _insercoesUsuario = [
    "INSERT INTO usuario (nome, email, cpf, senha, perfil, ativo) VALUES ('Ana Beatriz', 'professora@gmail.com', '11122233344', '123', 'professora', 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, perfil, ativo) VALUES ('Marina Torres', 'marina.torres@pulsestudio.com.br', '22233344455', '123', 'professora', 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, perfil, ativo) VALUES ('Paula Nogueira', 'paula.nogueira@pulsestudio.com.br', '33344455566', '123', 'professora', 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, perfil, ativo) VALUES ('Carlos Almeida', 'aluno@gmail.com', '55566677788', '123', 'aluno', 1)",
  ];

  static const List<String> _insercoesSala = [
    // posicao_professora = 3 → fila=(3-1)÷6+1=1 / coluna=(3-1)%6+1=3 → 0-based (0,2) = centro da 1ª fila
    "INSERT INTO sala (nome, numero_filas, numero_colunas, posicao_professora, ativa) VALUES ('Studio Sprint', 3, 6, 3, 1)",
    "INSERT INTO sala (nome, numero_filas, numero_colunas, posicao_professora, ativa) VALUES ('Studio Endurance', 3, 6, 3, 1)",
  ];

  static const List<String> _insercoesBike = [
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 01', 'PSI-BK-0001', 1, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 02', 'PSI-BK-0002', 2, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 03', 'PSI-BK-0003', 3, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 04', 'PSI-BK-0004', 4, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 05', 'PSI-BK-0005', 5, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 06', 'PSI-BK-0006', 1, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 07', 'PSI-BK-0007', 2, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 08', 'PSI-BK-0008', 3, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 09', 'PSI-BK-0009', 4, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 10', 'PSI-BK-0010', 5, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 11', 'PSI-BK-0011', 1, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 12', 'PSI-BK-0012', 2, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 13', 'PSI-BK-0013', 3, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 14', 'PSI-BK-0014', 4, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 15', 'PSI-BK-0015', 5, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 16', 'PSI-BK-0016', 1, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 17', 'PSI-BK-0017', 2, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 18', 'PSI-BK-0018', 3, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 19', 'PSI-BK-0019', 4, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 20', 'PSI-BK-0020', 5, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 21', 'PSI-BK-0021', 1, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 22', 'PSI-BK-0022', 2, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 23', 'PSI-BK-0023', 3, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 24', 'PSI-BK-0024', 4, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 25', 'PSI-BK-0025', 5, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 26', 'PSI-BK-0026', 1, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 27', 'PSI-BK-0027', 2, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 28', 'PSI-BK-0028', 3, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 29', 'PSI-BK-0029', 4, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 30', 'PSI-BK-0030', 5, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 31', 'PSI-BK-0031', 1, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 32', 'PSI-BK-0032', 2, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 33', 'PSI-BK-0033', 3, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 34', 'PSI-BK-0034', 4, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 35', 'PSI-BK-0035', 5, '2026-01-05T10:00:00', 1)",
    "INSERT INTO bike (nome, numero_serie, fabricante_id, data_cadastro, ativa) VALUES ('Bike 36', 'PSI-BK-0036', 1, '2026-01-05T10:00:00', 1)",
  ];

  static const List<String> _insercoesVideoAula = [
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Aquecimento Base', 'https://www.youtube.com/watch?v=4NRXx6U8ABQ', 1)",
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Sprint em Pe', 'https://www.youtube.com/watch?v=TUVcZfQe-Kw', 1)",
  ];

  static const List<String> _insercoesMusica = [
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Warm Wheels', 1, '[1]', '[1]', 'Aquecimento progressivo para preparar pedalada', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Ride the Fire', 2, '[1,2]', '[1,2]', 'Cadencia com foco em ritmo constante', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Climb Higher', 3, '[3]', '[2]', 'Subida com resistencia gradual', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Pulse Sprint', 1, '[2]', '[2]', 'Sprint curto para elevar frequencia cardiaca', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Deep Resistance', 3, '[3]', '[2]', 'Bloco de forca com carga alta', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Beat Control', 2, '[1,2]', '[1]', 'Controle de ritmo e respiracao', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Out of Saddle', 1, '[2,3]', '[2]', 'Trecho em pe com explosao controlada', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Final Push', 3, '[2,3]', '[2]', 'Bloco final de performance', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Slow Burn', 2, '[4]', '[1]', 'Desaceleracao ativa e controle de giro', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Cool Down Flow', 1, '[4]', '[1]', 'Relaxamento e alongamento final', 1)",
  ];

  static const List<String> comandosGarantirMixDezMusicas = [
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (1, 'Warm Wheels', 1, '[1]', '[1]', 'Aquecimento progressivo para preparar pedalada', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (2, 'Ride the Fire', 2, '[1,2]', '[1,2]', 'Cadencia com foco em ritmo constante', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (3, 'Climb Higher', 3, '[3]', '[2]', 'Subida com resistencia gradual', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (4, 'Pulse Sprint', 1, '[2]', '[2]', 'Sprint curto para elevar frequencia cardiaca', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (5, 'Deep Resistance', 3, '[3]', '[2]', 'Bloco de forca com carga alta', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (6, 'Beat Control', 2, '[1,2]', '[1]', 'Controle de ritmo e respiracao', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (7, 'Out of Saddle', 1, '[2,3]', '[2]', 'Trecho em pe com explosao controlada', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (8, 'Final Push', 3, '[2,3]', '[2]', 'Bloco final de performance', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (9, 'Slow Burn', 2, '[4]', '[1]', 'Desaceleracao ativa e controle de giro', 1)",
    "INSERT OR IGNORE INTO musica (id, nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES (10, 'Cool Down Flow', 1, '[4]', '[1]', 'Relaxamento e alongamento final', 1)",
    "UPDATE mix SET musica_ids = '[1,2,3,4,5,6,7,8,9,10]' WHERE id = 1",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 1, 1)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 2, 2)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 3, 3)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 4, 4)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 5, 5)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 6, 6)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 7, 7)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 8, 8)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 9, 9)",
    "INSERT OR IGNORE INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 10, 10)",
  ];

  static const List<String> comandosNormalizarSeedsContextoReal = [];

  static const List<String> _insercoesMix = [
    "INSERT INTO mix (nome, musica_ids, descricao, ativo) VALUES ('Mix Power Ride', '[1,2,3,4,5,6,7,8,9,10]', 'Sequencia completa para aula de power ride com aquecimento, forca, sprint e desaceleracao', 1)",
    "INSERT INTO mix (nome, musica_ids, descricao, ativo) VALUES ('Mix Sprint HIIT', '[2,4,7,8,5,6,3,1,9,10]', 'Mix de spinning com tiros intensos, recuperacao curta e fechamento controlado', 1)",
    "INSERT INTO mix (nome, musica_ids, descricao, ativo) VALUES ('Mix Climb Endurance', '[1,3,5,6,7,8,2,4,9,10]', 'Mix de subida progressiva e resistencia para aula longa de endurance', 1)",
    "INSERT INTO mix (nome, musica_ids, descricao, ativo) VALUES ('Mix Rhythm Recovery', '[1,6,2,3,9,5,7,8,10,4]', 'Mix de ritmo moderado para tecnica, cadencia e recuperacao ativa', 1)",
  ];

  static const List<String> _insercoesMusicaCategoria = [
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (1, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (1, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (2, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (2, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (3, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (4, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (5, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (6, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (6, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (7, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (7, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (8, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (8, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (9, 4)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (10, 4)",
  ];

  static const List<String> _insercoesMusicaVideoAula = [
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (1, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (2, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (2, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (3, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (4, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (5, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (6, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (7, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (8, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (9, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (10, 1)",
  ];

  static const List<String> _insercoesMixMusica = [
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 1, 1)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 2, 2)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 3, 3)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 4, 4)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 5, 5)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 6, 6)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 7, 7)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 8, 8)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 9, 9)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (1, 10, 10)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 2, 1)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 4, 2)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 7, 3)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 8, 4)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 5, 5)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 6, 6)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 3, 7)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 1, 8)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 9, 9)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (2, 10, 10)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 1, 1)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 3, 2)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 5, 3)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 6, 4)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 7, 5)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 8, 6)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 2, 7)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 4, 8)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 9, 9)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (3, 10, 10)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 1, 1)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 6, 2)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 2, 3)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 3, 4)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 9, 5)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 5, 6)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 7, 7)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 8, 8)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 10, 9)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (4, 4, 10)",
  ];

  static const List<String> _insercoesTurma = [
    "INSERT INTO turma (nome, descricao, dias_semana, horario_inicio, duracao_minutos, sala_id, ativo) VALUES ('Power Ride 07h', 'Aula de spinning intensa para alunos de uso frequente, com blocos de forca e sprint', '[\"Seg\",\"Qua\",\"Sex\"]', '07:00', 50, 1, 1)",
    "INSERT INTO turma (nome, descricao, dias_semana, horario_inicio, duracao_minutos, sala_id, ativo) VALUES ('Sprint HIIT 12h', 'Aula curta de spinning com tiros de alta intensidade e recuperacao controlada', '[\"Ter\",\"Qui\"]', '12:00', 45, 1, 1)",
    "INSERT INTO turma (nome, descricao, dias_semana, horario_inicio, duracao_minutos, sala_id, ativo) VALUES ('Climb Endurance 18h30', 'Treino de subida e resistencia progressiva para fim de tarde', '[\"Seg\",\"Qua\",\"Sex\"]', '18:30', 55, 2, 1)",
    "INSERT INTO turma (nome, descricao, dias_semana, horario_inicio, duracao_minutos, sala_id, ativo) VALUES ('Rhythm Recovery 20h', 'Aula de ritmo moderado, tecnica de pedalada e recuperacao ativa', '[\"Ter\",\"Qui\"]', '20:00', 45, 2, 1)",
  ];

  static const List<String> _insercoesTurmaDiaSemana = [
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Power Ride 07h' LIMIT 1), 'Seg')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Power Ride 07h' LIMIT 1), 'Qua')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Power Ride 07h' LIMIT 1), 'Sex')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Sprint HIIT 12h' LIMIT 1), 'Ter')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Sprint HIIT 12h' LIMIT 1), 'Qui')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Climb Endurance 18h30' LIMIT 1), 'Seg')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Climb Endurance 18h30' LIMIT 1), 'Qua')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Climb Endurance 18h30' LIMIT 1), 'Sex')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Rhythm Recovery 20h' LIMIT 1), 'Ter')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Rhythm Recovery 20h' LIMIT 1), 'Qui')",
  ];

  static const List<String> _insercoesGrupoAlunos = [
    "INSERT INTO grupo_alunos (nome, descricao, aluno_ids, ativo) VALUES ('Uso Intenso', 'Alunos com alta frequencia semanal nas aulas de spinning', '[1,2,3,4,5,6,7,8,9,10]', 1)",
    "INSERT INTO grupo_alunos (nome, descricao, aluno_ids, ativo) VALUES ('Iniciantes Spinning', 'Alunos em fase inicial, com foco em tecnica, ajuste de bike e controle de carga', '[11,12,13,14,15]', 1)",
    "INSERT INTO grupo_alunos (nome, descricao, aluno_ids, ativo) VALUES ('Medianos em Evolucao', 'Alunos com frequencia regular e evolucao em ritmo, forca e resistencia', '[16,17,18,19,20]', 1)",
  ];

  static const List<String> _insercoesGrupoAluno = [
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 1)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 2)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 3)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 4)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 5)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 6)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 7)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 8)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 9)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Uso Intenso' LIMIT 1), 10)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Iniciantes Spinning' LIMIT 1), 11)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Iniciantes Spinning' LIMIT 1), 12)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Iniciantes Spinning' LIMIT 1), 13)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Iniciantes Spinning' LIMIT 1), 14)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Iniciantes Spinning' LIMIT 1), 15)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Medianos em Evolucao' LIMIT 1), 16)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Medianos em Evolucao' LIMIT 1), 17)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Medianos em Evolucao' LIMIT 1), 18)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Medianos em Evolucao' LIMIT 1), 19)",
    "INSERT INTO grupo_aluno (grupo_alunos_id, aluno_id) VALUES ((SELECT id FROM grupo_alunos WHERE nome = 'Medianos em Evolucao' LIMIT 1), 20)",
  ];

  static const List<String> _insercoesTurmaMix = [
    "INSERT INTO turma_mix (turma_id, mix_id, data_inicio, data_fim, ativo) VALUES (1, 1, '2026-01-01T00:00:00', '2026-12-31T23:59:59', 1)",
    "INSERT INTO turma_mix (turma_id, mix_id, data_inicio, data_fim, ativo) VALUES (2, 2, '2026-01-01T00:00:00', '2026-12-31T23:59:59', 1)",
    "INSERT INTO turma_mix (turma_id, mix_id, data_inicio, data_fim, ativo) VALUES (3, 3, '2026-01-01T00:00:00', '2026-12-31T23:59:59', 1)",
    "INSERT INTO turma_mix (turma_id, mix_id, data_inicio, data_fim, ativo) VALUES (4, 4, '2026-01-01T00:00:00', '2026-12-31T23:59:59', 1)",
  ];

  // Grid operacional 3x6 compartilhado pelas salas do seed.
  // Studio Sprint e Studio Endurance possuem 3 filas e 6 colunas.
  // A coluna 2 da primeira fila representa a professora no mapa da sala,
  // restando 17 posicoes reservaveis para alunos em cada sala.
  // A tabela posicao_bike atual nao possui sala_id; por isso as posicoes
  // descrevem o mapa fisico usado por salas com a mesma configuracao.
  static const List<String> _insercoesPosicaoBike = [
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (0, 0, 1)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (0, 1, 2)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (0, 2, 3)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (0, 3, 4)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (0, 4, 5)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (0, 5, 6)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (1, 0, 7)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (1, 1, 8)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (1, 2, 9)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (1, 3, 10)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (1, 4, 11)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (1, 5, 12)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (2, 0, 13)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (2, 1, 14)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (2, 2, 15)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (2, 3, 16)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (2, 4, 17)",
    "INSERT INTO posicao_bike (fila, coluna, bike_id) VALUES (2, 5, 18)",
  ];

  static const List<String> _insercoesManutencao = [
    "INSERT INTO manutencao (bike_id, tipo_manutencao_id, data_solicitacao, data_realizacao, descricao, estado_operacional, ativo) VALUES (3, 1, '2026-03-25T08:00:00', '2026-04-05T08:00:00', 'Pedal com folga', 'realizado', 1)",
    "INSERT INTO manutencao (bike_id, tipo_manutencao_id, data_solicitacao, descricao, estado_operacional, ativo) VALUES (7, 2, '2026-03-28T09:00:00', 'Altura do banco desregulada', 'cancelado', 0)",
    "INSERT INTO manutencao (bike_id, tipo_manutencao_id, data_solicitacao, data_realizacao, descricao, estado_operacional, ativo) VALUES (5, 3, '2026-04-01T10:00:00', '2026-04-01T10:00:00', 'Banco com rachadura, necessita troca', 'realizado', 1)",
    "INSERT INTO manutencao (bike_id, tipo_manutencao_id, data_solicitacao, descricao, estado_operacional, ativo) VALUES (9, 1, '2026-04-03T07:30:00', 'Pedal esquerdo travando', 'pendente', 1)",
    "INSERT INTO manutencao (bike_id, tipo_manutencao_id, data_solicitacao, descricao, estado_operacional, ativo) VALUES (2, 4, '2026-04-10T09:00:00', 'Correia fazendo barulho durante o pedal', 'em_andamento', 1)",
  ];

  static const List<String> _insercoesCheckin = [
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, 1, '2026-03-02T07:00:00', 1, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, 3, '2026-03-04T18:30:00', 1, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, 1, '2026-03-06T07:00:00', 1, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, 3, '2026-03-09T07:00:00', 1, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, 1, '2026-03-11T18:30:00', 1, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, 3, '2026-03-13T07:00:00', 2, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, 1, '2026-03-02T07:00:00', 1, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, 3, '2026-03-04T18:30:00', 1, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, 1, '2026-03-06T07:00:00', 1, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, 3, '2026-03-09T07:00:00', 1, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, 1, '2026-03-11T18:30:00', 2, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, 3, '2026-03-13T07:00:00', 2, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, 1, '2026-03-02T07:00:00', 1, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, 3, '2026-03-04T18:30:00', 1, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, 1, '2026-03-06T07:00:00', 1, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, 3, '2026-03-09T07:00:00', 2, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, 1, '2026-03-11T18:30:00', 2, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, 3, '2026-03-13T07:00:00', 2, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, 1, '2026-03-02T07:00:00', 1, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, 3, '2026-03-04T18:30:00', 1, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, 1, '2026-03-06T07:00:00', 2, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, 3, '2026-03-09T07:00:00', 2, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, 1, '2026-03-11T18:30:00', 2, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, 3, '2026-03-13T07:00:00', 2, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, 1, '2026-03-02T07:00:00', 1, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, 3, '2026-03-04T18:30:00', 2, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, 1, '2026-03-06T07:00:00', 2, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, 3, '2026-03-09T07:00:00', 2, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, 1, '2026-03-11T18:30:00', 2, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, 3, '2026-03-13T07:00:00', 2, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, 1, '2026-03-02T07:00:00', 2, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, 3, '2026-03-04T18:30:00', 2, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, 1, '2026-03-06T07:00:00', 2, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, 3, '2026-03-09T07:00:00', 2, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, 1, '2026-03-11T18:30:00', 2, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, 3, '2026-03-13T07:00:00', 2, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, 1, '2026-03-02T07:00:00', 2, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, 3, '2026-03-04T18:30:00', 2, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, 1, '2026-03-06T07:00:00', 2, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, 3, '2026-03-09T07:00:00', 2, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, 1, '2026-03-11T18:30:00', 2, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, 3, '2026-03-13T07:00:00', 0, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, 1, '2026-03-02T07:00:00', 2, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, 3, '2026-03-04T18:30:00', 2, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, 1, '2026-03-06T07:00:00', 2, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, 3, '2026-03-09T07:00:00', 2, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, 1, '2026-03-11T18:30:00', 0, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, 3, '2026-03-13T07:00:00', 0, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, 1, '2026-03-02T07:00:00', 2, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, 3, '2026-03-04T18:30:00', 2, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, 1, '2026-03-06T07:00:00', 2, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, 3, '2026-03-09T07:00:00', 0, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, 1, '2026-03-11T18:30:00', 0, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (9, 3, '2026-03-13T07:00:00', 0, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, 1, '2026-03-02T07:00:00', 2, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, 3, '2026-03-04T18:30:00', 2, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, 1, '2026-03-06T07:00:00', 0, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, 3, '2026-03-09T07:00:00', 0, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, 1, '2026-03-11T18:30:00', 0, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (10, 3, '2026-03-13T07:00:00', 0, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (11, 4, '2026-03-03T20:00:00', 2, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (11, 4, '2026-03-10T20:00:00', 0, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (12, 4, '2026-03-03T20:00:00', 0, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (12, 4, '2026-03-10T20:00:00', 0, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (13, 4, '2026-03-03T20:00:00', 0, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (13, 4, '2026-03-10T20:00:00', 0, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (14, 4, '2026-03-03T20:00:00', 0, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (14, 4, '2026-03-10T20:00:00', 0, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (15, 4, '2026-03-03T20:00:00', 0, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (15, 4, '2026-03-10T20:00:00', 0, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (16, 2, '2026-03-03T12:00:00', 0, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (16, 2, '2026-03-10T12:00:00', 1, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (16, 3, '2026-03-17T18:30:00', 1, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (17, 2, '2026-03-03T12:00:00', 1, 0, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (17, 2, '2026-03-10T12:00:00', 1, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (17, 3, '2026-03-17T18:30:00', 1, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (18, 2, '2026-03-03T12:00:00', 1, 1, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (18, 2, '2026-03-10T12:00:00', 1, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (18, 3, '2026-03-17T18:30:00', 1, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (19, 2, '2026-03-03T12:00:00', 1, 2, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (19, 2, '2026-03-10T12:00:00', 1, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (19, 3, '2026-03-17T18:30:00', 1, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (20, 2, '2026-03-03T12:00:00', 1, 3, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (20, 2, '2026-03-10T12:00:00', 1, 4, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (20, 3, '2026-03-17T18:30:00', 1, 5, 1)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, 3, '2026-03-18T18:30:00', 1, 0, 0)",
    "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (12, 4, '2026-03-17T20:00:00', 2, 5, 0)",
  ];

  static const List<String> _insercoesFilaEspera = [
    "INSERT INTO fila_espera_checkin (aluno_id, turma_id, data, criado_em, ativo) VALUES (11, 1, '2026-03-13T07:00:00', '2026-03-13T06:45:00', 1)",
    "INSERT INTO fila_espera_checkin (aluno_id, turma_id, data, criado_em, ativo) VALUES (12, 3, '2026-03-13T18:30:00', '2026-03-13T18:10:00', 1)",
  ];

  static const List<List<String>> comandosInsercoes = [
    _insercoesFabricante,
    _insercoesCategoriaMusica,
    _insercoesTipoManutencao,
    _insercoesArtistaBanda,
    _insercoesAluno,
    _insercoesUsuario,
    _insercoesSala,
    _insercoesBike,
    _insercoesVideoAula,
    _insercoesMusica,
    _insercoesMusicaCategoria,
    _insercoesMusicaVideoAula,
    _insercoesMix,
    _insercoesMixMusica,
    _insercoesTurma,
    _insercoesTurmaDiaSemana,
    _insercoesGrupoAlunos,
    _insercoesGrupoAluno,
    _insercoesTurmaMix,
    _insercoesPosicaoBike,
    _insercoesManutencao,
    _insercoesCheckin,
    _insercoesFilaEspera,
  ];

  static List<String> comandosInsercoesDinamicas(DateTime agora) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final amanha = hoje.add(const Duration(days: 1));

    // Cenario 1 — FECHADA: janela ainda nao abriu (inicia em 31 min)
    final horaAula1 = agora.add(const Duration(minutes: 31));
    // Cenario 2 — COM VAGAS: janela aberta ha 15 min (inicia em 15 min)
    final horaAula2 = agora.add(const Duration(minutes: 15));
    // Cenario 3 — LOTADA: janela aberta ha 20 min (inicia em 10 min), sala minuscula cheia
    final horaAulaLotada = agora.add(const Duration(minutes: 10));

    final horario1 = _formatarHora(horaAula1);
    final horario2 = _formatarHora(horaAula2);
    final horarioLotada = _formatarHora(horaAulaLotada);

    final hojeIso = hoje.toIso8601String();
    final ontemIso = ontem.toIso8601String();
    final amanhaIso = amanha.toIso8601String();
    final criadoFila = agora
        .subtract(const Duration(minutes: 5))
        .toIso8601String();

    final diaHoje = _siglaDiaSemana(hoje.weekday);
    final diaAmanha = _siglaDiaSemana(amanha.weekday);

    // Nomes dos recursos dinamicos
    const nomeTurmaFechada = 'Cadencia Base Hoje';
    const nomeTurmaVagas = 'Power Ride Hoje';
    const nomeTurmaLotada = 'Sprint Lotado Hoje';

    return [
      // Turmas dinamicas sobre as duas salas oficiais do seed.
      "INSERT INTO turma (nome, descricao, dias_semana, horario_inicio, duracao_minutos, sala_id, ativo) VALUES ('$nomeTurmaFechada', 'Aula de spinning para tecnica de pedalada e controle de cadencia', '[\"$diaHoje\"]', '$horario1', 50, (SELECT id FROM sala WHERE nome = 'Studio Sprint' LIMIT 1), 1)",
      "INSERT INTO turma (nome, descricao, dias_semana, horario_inicio, duracao_minutos, sala_id, ativo) VALUES ('$nomeTurmaVagas', 'Aula de spinning com foco em ritmo, forca e resistencia', '[\"$diaHoje\"]', '$horario2', 50, (SELECT id FROM sala WHERE nome = 'Studio Sprint' LIMIT 1), 1)",
      "INSERT INTO turma (nome, descricao, dias_semana, horario_inicio, duracao_minutos, sala_id, ativo) VALUES ('$nomeTurmaLotada', 'Aula de spinning intensa para alunos com maior condicionamento', '[\"$diaHoje\",\"$diaAmanha\"]', '$horarioLotada', 45, (SELECT id FROM sala WHERE nome = 'Studio Endurance' LIMIT 1), 1)",

      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaFechada' ORDER BY id DESC LIMIT 1), '$diaHoje')",
      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), '$diaHoje')",
      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$diaHoje')",
      "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$diaAmanha')",

      "INSERT INTO turma_mix (turma_id, mix_id, data_inicio, data_fim, ativo) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaFechada' ORDER BY id DESC LIMIT 1), 4, '$hojeIso', '$amanhaIso', 1)",
      "INSERT INTO turma_mix (turma_id, mix_id, data_inicio, data_fim, ativo) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), 1, '$ontemIso', '$amanhaIso', 1)",
      "INSERT INTO turma_mix (turma_id, mix_id, data_inicio, data_fim, ativo) VALUES ((SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), 2, '$hojeIso', '$amanhaIso', 1)",

      // Power Ride Hoje: sala com vagas.
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (1, (SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), '$ontemIso', 1, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, (SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, (SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 1, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, (SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, (SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 2, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, (SELECT id FROM turma WHERE nome = '$nomeTurmaVagas' ORDER BY id DESC LIMIT 1), '$hojeIso', 2, 1, 1)",

      // Sprint Lotado Hoje: 17 posicoes reservaveis preenchidas; coluna 2 da fila 0 representa a professora.
      // aluno@gmail.com (id=1) nao tem check-in aqui → vera status LOTADA e podera entrar na fila.
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (20, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (2, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 1, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (3, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 3, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (4, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 4, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (5, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 0, 5, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (6, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 0, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (7, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 1, 1)",
      "INSERT INTO checkin (aluno_id, turma_id, data, fila, coluna, ativo) VALUES (8, (SELECT id FROM turma WHERE nome = '$nomeTurmaLotada' ORDER BY id DESC LIMIT 1), '$hojeIso', 1, 2, 1)",
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
