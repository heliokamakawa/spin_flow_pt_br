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
      aluno_id INTEGER,
      professora_id INTEGER,
      ativo INTEGER NOT NULL DEFAULT 1,
      FOREIGN KEY(aluno_id) REFERENCES aluno(id),
      FOREIGN KEY(professora_id) REFERENCES professora(id)
    )
  ''';

  static const String _criarTabelaProfessora = '''
    CREATE TABLE professora (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
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

  static const String criarTabelaProfessoraSeNaoExistir = '''
    CREATE TABLE IF NOT EXISTS professora (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String adicionarAlunoIdUsuario = '''
    ALTER TABLE usuario ADD COLUMN aluno_id INTEGER
  ''';

  static const String adicionarProfessoraIdUsuario = '''
    ALTER TABLE usuario ADD COLUMN professora_id INTEGER
  ''';

  static const String _criarTabelaTurma = '''
    CREATE TABLE turma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      horario_inicio TEXT NOT NULL,
      duracao_minutos INTEGER NOT NULL,
      sala_id INTEGER,
      professora_id INTEGER,
      mix_id INTEGER,
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

  static const String _criarTabelaAulaRealizada = '''
    CREATE TABLE aula_realizada (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      aluno_id INTEGER NOT NULL,
      turma_id INTEGER NOT NULL,
      data TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1,
      UNIQUE(aluno_id, turma_id, data),
      FOREIGN KEY(aluno_id) REFERENCES aluno(id),
      FOREIGN KEY(turma_id) REFERENCES turma(id)
    )
  ''';

  static const String criarTabelaAulaRealizadaSeNaoExistir = '''
    CREATE TABLE IF NOT EXISTS aula_realizada (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      aluno_id INTEGER NOT NULL,
      turma_id INTEGER NOT NULL,
      data TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1,
      UNIQUE(aluno_id, turma_id, data),
      FOREIGN KEY(aluno_id) REFERENCES aluno(id),
      FOREIGN KEY(turma_id) REFERENCES turma(id)
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
    _criarTabelaProfessora,
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
    _criarTabelaAulaRealizada,
    _criarTabelaFilaEsperaCheckin,
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
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1990-05-15', 'feminino', '(11) 99999-1101', '', '@anaclaraspinning', '', '', 'Uso intenso: aluna de alta frequencia, treina spinning de 4 a 5 vezes por semana e costuma reservar primeira fileira', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1995-07-08', 'feminino', '(11) 99999-1102', '', '@fernandalima.ride', '', '', 'Uso intenso: alta frequencia nas turmas da noite e preferencia por aulas de endurance', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1991-09-14', 'masculino', '(11) 99999-1103', '', '@robertogomes.fit', '', '', 'Uso intenso: participa de treinos de sprint e acompanha indicadores de evolucao', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1994-06-03', 'feminino', '(11) 99999-1104', '', '@jumartins.spin', '', '', 'Uso intenso: aluna recorrente nas aulas da manha e costuma avaliar repertorios', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1987-01-25', 'feminino', '(11) 99999-1105', '', '@patricia.souza.indoor', '', '', 'Uso intenso: treina em turmas avancadas e alterna bikes centrais', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1993-11-30', 'masculino', '(11) 99999-1106', '', '@lucasoliveira_spin', '', '', 'Uso intenso: preferencia por aulas de subida e resistencia no fim do dia', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1992-12-10', 'feminino', '(11) 99999-1107', '', '@maricosta.bike', '', '', 'Uso intenso: frequenta quatro aulas por semana e prioriza bikes da lateral direita', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1989-02-19', 'masculino', '(11) 99999-1108', '', '', '', '', 'Uso intenso: foco em condicionamento cardiovascular e aulas HIIT', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1996-10-21', 'feminino', '(11) 99999-1109', '', '@camilateixeira.cycling', '', '', 'Uso intenso: aluna assidua em rhythm ride e sprints curtos', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1986-04-12', 'masculino', '(11) 99999-1110', '', '@rafamonteiro.ride', '', '', 'Uso intenso: participa de desafios internos e acompanha historico semanal', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1985-08-22', 'masculino', '(11) 99999-1111', '', '', '', '', 'Iniciante: em adaptacao ao spinning, prefere aulas de tecnica e baixa intensidade', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1998-01-18', 'feminino', '(11) 99999-1112', '', '@brunaandrade.fit', '', '', 'Iniciante: primeiras semanas de treino, orientada a usar bikes de facil acesso', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1997-05-27', 'feminino', '(11) 99999-1113', '', '@elainecardoso', '', '', 'Iniciante: retorno gradual aos treinos e acompanhamento de carga moderada', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1990-08-09', 'masculino', '(11) 99999-1114', '', '', '', '', 'Iniciante: foco em aprender cadencia e ajuste correto da bike', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1999-03-16', 'feminino', '(11) 99999-1115', '', '@larissamelo.spin', '', '', 'Iniciante: prefere aulas de base e acompanhamento proximo da professora', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1992-07-11', 'feminino', '(11) 99999-1116', '', '@mariacosta.bike', '', '', 'Mediano: participa duas vezes por semana e alterna entre ritmo e subida', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1988-03-20', 'masculino', '(11) 99999-1117', '', '@carlospereira.cycling', '', '', 'Mediano: frequencia regular, bom desempenho em aulas de resistencia', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1991-06-24', 'feminino', '(11) 99999-1118', '', '@anaribeiro.ride', '', '', 'Mediano: prefere turmas no almoco e ritmos constantes', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1984-12-02', 'masculino', '(11) 99999-1119', '', '@pedrolima.spin', '', '', 'Mediano: participa de treinos funcionais e spinning em dias alternados', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1993-09-05', 'feminino', '(11) 99999-1120', '', '@sabrinaduarte.indoor', '', '', 'Mediano: boa adaptacao a sprint, ainda evoluindo em aulas longas', 1)",
    "INSERT INTO aluno (data_nascimento, genero, telefone, url_foto, instagram, facebook, tiktok, observacoes, ativo) VALUES ('1985-03-20', 'feminino', '(11) 99999-0001', '', '@anabeatriz.spinflow', '', '', 'Professora e aluna — perfil criado para teste do fluxo duplo', 1)",
  ];

  static const List<String> _insercoesProfessora = [
    "INSERT INTO professora (ativo) VALUES (1)",
    "INSERT INTO professora (ativo) VALUES (1)",
    "INSERT INTO professora (ativo) VALUES (1)",
    "INSERT INTO professora (ativo) VALUES (1)",
  ];

  static const List<String> _insercoesUsuario = [
    "INSERT INTO usuario (nome, email, cpf, senha, professora_id, ativo) VALUES ('Ana Beatriz', 'professora@gmail.com', '11122233344', '123', 1, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, professora_id, ativo) VALUES ('Marina Torres', 'marina.torres@pulsestudio.com.br', '22233344455', '123', 2, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, professora_id, ativo) VALUES ('Paula Nogueira', 'paula.nogueira@pulsestudio.com.br', '33344455566', '123', 3, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, professora_id, ativo) VALUES ('Ricardo Mendes', 'ricardo.mendes@pulsestudio.com.br', '44455566677', '123', 4, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Ana Clara Almeida', 'aluna@gmail.com', '55566677788', '123', 1, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Fernanda Lima', 'fernanda.lima@email.com', '55566677789', '123', 2, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Roberto Gomes', 'roberto.gomes@email.com', '55566677790', '123', 3, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Juliana Martins', 'juliana.martins@email.com', '55566677791', '123', 4, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Patricia Souza', 'patricia.souza@email.com', '55566677792', '123', 5, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Lucas Oliveira', 'lucas.oliveira@email.com', '55566677793', '123', 6, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Mariana Costa', 'mariana.costa@email.com', '55566677794', '123', 7, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Diego Matos', 'diego.matos@email.com', '55566677795', '123', 8, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Camila Teixeira', 'camila.teixeira@email.com', '55566677796', '123', 9, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Rafael Monteiro', 'rafael.monteiro@email.com', '55566677797', '123', 10, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Joao Santos', 'joao.santos@email.com', '55566677798', '123', 11, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Bruna Andrade', 'bruna.andrade@email.com', '55566677799', '123', 12, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Elaine Cardoso', 'elaine.cardoso@email.com', '55566677800', '123', 13, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Igor Pacheco', 'igor.pacheco@email.com', '55566677801', '123', 14, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Larissa Melo', 'larissa.melo@email.com', '55566677802', '123', 15, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Maria Costa', 'maria.costa@email.com', '55566677803', '123', 16, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Carlos Pereira', 'carlos.pereira@email.com', '55566677804', '123', 17, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Ana Ribeiro', 'ana.ribeiro@email.com', '55566677805', '123', 18, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Pedro Lima', 'pedro.lima@email.com', '55566677806', '123', 19, 1)",
    "INSERT INTO usuario (nome, email, cpf, senha, aluno_id, ativo) VALUES ('Sabrina Duarte', 'sabrina.duarte@email.com', '55566677807', '123', 20, 1)",
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
    // id 1
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Aquecimento Base', 'https://www.youtube.com/watch?v=4NRXx6U8ABQ', 1)",
    // id 2
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Sprint em Pe', 'https://www.youtube.com/watch?v=TUVcZfQe-Kw', 1)",
    // id 3
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Cadencia e Postura', 'https://www.youtube.com/watch?v=pRxEfLhmPkU', 1)",
    // id 4
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Subida Progressiva', 'https://www.youtube.com/watch?v=W9TqFMSdflU', 1)",
    // id 5
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Tecnica de Sprint', 'https://www.youtube.com/watch?v=MN3x-kAbgFU', 1)",
    // id 6
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Forca em Carga Alta', 'https://www.youtube.com/watch?v=CevxZvSJLk8', 1)",
    // id 7
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Aquecimento Dinamico', 'https://www.youtube.com/watch?v=9bZkp7q19f0', 1)",
    // id 8
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Recuperacao Ativa', 'https://www.youtube.com/watch?v=kJQP7kiw5Fk', 1)",
    // id 9
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Ritmo Constante', 'https://www.youtube.com/watch?v=OPf0YbXqDm0', 1)",
    // id 10
    "INSERT INTO video_aula (nome, link_video, ativo) VALUES ('Relaxamento Final', 'https://www.youtube.com/watch?v=GIs9pk9eFj4', 1)",
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
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Morning Cadence', 2, '[1,5]', '[1]', 'Entrada leve com foco em cadencia e postura', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Gear Shift', 3, '[1,3]', '[2]', 'Trocas de carga para simular terreno variado', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Neon Climb', 1, '[3]', '[2]', 'Subida longa com resistencia progressiva', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Tempo Rider', 2, '[1,2]', '[1]', 'Ritmo constante para manter giro controlado', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Power Surge', 3, '[2,3]', '[2]', 'Explosao de potencia em bloco curto', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Recovery Spin', 1, '[4]', '[1]', 'Recuperacao ativa entre blocos intensos', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Hill Attack', 3, '[3]', '[2]', 'Ataque de subida com carga firme', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Rhythm Pulse', 2, '[1,2]', '[1]', 'Sequencia ritmada para sincronizar turma', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Sprint Signal', 1, '[2]', '[2]', 'Sinal de sprint com aceleracao progressiva', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Steady Road', 2, '[1]', '[1]', 'Trecho estavel para tecnica de pedalada', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Torque Zone', 3, '[3]', '[2]', 'Zona de torque para fortalecer pernas', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Breath Line', 1, '[4]', '[1]', 'Controle respiratorio e reducao gradual de carga', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Peak Minute', 2, '[2,3]', '[2]', 'Minuto de pico para performance maxima', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Base Builder', 3, '[1,5]', '[1]', 'Construcao de base aerobica no aquecimento', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Fast Lane', 1, '[2]', '[2]', 'Linha rapida para tiros sentados', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Climb Control', 3, '[1,3]', '[2]', 'Subida controlada com foco em cadencia baixa', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Heat Wave Ride', 2, '[2,5]', '[1,2]', 'Aquecimento intenso antes dos sprints', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Silent Coast', 1, '[4]', '[1]', 'Descompressao final com giro solto', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Resistance Loop', 3, '[3]', '[2]', 'Repeticoes de resistencia para endurance', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Cadence Lock', 2, '[1,2]', '[1]', 'Trava de cadencia para trabalho tecnico', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Fuel the Pack', 1, '[2,3]', '[2]', 'Bloco coletivo de energia e superacao', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Low Gear Flow', 2, '[1,4]', '[1]', 'Giro leve em baixa carga para transicao', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Breakaway Beat', 3, '[2]', '[2]', 'Arrancada curta simulando fuga do pelotao', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Standing Drive', 1, '[2,3]', '[2]', 'Pedalada em pe com carga moderada', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Soft Landing', 2, '[4]', '[1]', 'Fechamento suave para alongamento e relaxamento', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Endurance Rail', 3, '[1,3]', '[2]', 'Trilho de endurance com subida prolongada', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Pulse Ladder', 1, '[2]', '[2]', 'Escada de frequencia com tiros crescentes', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Warm Horizon', 2, '[5]', '[1]', 'Aquecimento inicial para aulas de resistencia', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Summit Hold', 3, '[3]', '[2]', 'Sustentacao no topo da subida com carga alta', 1)",
    "INSERT INTO musica (nome, artista_id, categoria_ids, video_aula_ids, descricao, ativo) VALUES ('Final Breath', 1, '[4]', '[1]', 'Respiracao final e retorno a calma', 1)",
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
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (11, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (11, 5)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (12, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (12, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (13, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (14, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (14, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (15, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (15, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (16, 4)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (17, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (18, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (18, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (19, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (20, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (21, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (22, 4)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (23, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (23, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (24, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (24, 5)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (25, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (26, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (26, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (27, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (27, 5)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (28, 4)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (29, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (30, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (30, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (31, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (31, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (32, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (32, 4)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (33, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (34, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (34, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (35, 4)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (36, 1)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (36, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (37, 2)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (38, 5)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (39, 3)",
    "INSERT INTO musica_categoria (musica_id, categoria_id) VALUES (40, 4)",
  ];

  static const List<String> _insercoesMusicaVideoAula = [
    // 1 Warm Wheels — aquecimento (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (1, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (1, 7)",
    // 2 Ride the Fire — cadencia (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (2, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (2, 3)",
    // 3 Climb Higher — subida (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (3, 4)",
    // 4 Pulse Sprint — sprint (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (4, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (4, 5)",
    // 5 Deep Resistance — forca (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (5, 6)",
    // 6 Beat Control — cadencia (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (6, 3)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (6, 9)",
    // 7 Out of Saddle — em pe (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (7, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (7, 5)",
    // 8 Final Push — performance final (3 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (8, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (8, 5)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (8, 6)",
    // 9 Slow Burn — recuperacao (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (9, 8)",
    // 10 Cool Down Flow — relaxamento (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (10, 10)",
    // 11 Morning Cadence — aquecimento (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (11, 1)",
    // 12 Gear Shift — forca (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (12, 6)",
    // 13 Neon Climb — subida (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (13, 4)",
    // 14 Tempo Rider — cadencia (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (14, 3)",
    // 15 Power Surge — em pe / forca (3 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (15, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (15, 5)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (15, 6)",
    // 16 Recovery Spin — recuperacao (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (16, 8)",
    // 17 Hill Attack — subida (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (17, 4)",
    // 18 Rhythm Pulse — ritmo (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (18, 9)",
    // 19 Sprint Signal — sprint (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (19, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (19, 5)",
    // 20 Steady Road — cadencia / ritmo (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (20, 3)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (20, 9)",
    // 21 Torque Zone — forca (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (21, 6)",
    // 22 Breath Line — recuperacao (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (22, 8)",
    // 23 Peak Minute — em pe / sprint (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (23, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (23, 5)",
    // 24 Base Builder — aquecimento (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (24, 7)",
    // 25 Fast Lane — sprint (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (25, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (25, 5)",
    // 26 Climb Control — subida (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (26, 4)",
    // 27 Heat Wave Ride — aquecimento intenso (3 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (27, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (27, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (27, 7)",
    // 28 Silent Coast — relaxamento (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (28, 10)",
    // 29 Resistance Loop — subida / forca (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (29, 4)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (29, 6)",
    // 30 Cadence Lock — cadencia / ritmo (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (30, 3)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (30, 9)",
    // 31 Fuel the Pack — em pe (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (31, 5)",
    // 32 Low Gear Flow — recuperacao (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (32, 8)",
    // 33 Breakaway Beat — sprint (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (33, 2)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (33, 5)",
    // 34 Standing Drive — em pe (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (34, 5)",
    // 35 Soft Landing — relaxamento (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (35, 10)",
    // 36 Endurance Rail — subida (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (36, 4)",
    // 37 Pulse Ladder — sprint (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (37, 2)",
    // 38 Warm Horizon — aquecimento (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (38, 1)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (38, 7)",
    // 39 Summit Hold — subida / forca (2 vídeos)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (39, 4)",
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (39, 6)",
    // 40 Final Breath — relaxamento (1 vídeo)
    "INSERT INTO musica_video_aula (musica_id, video_aula_id) VALUES (40, 10)",
  ];

  static const List<String> _insercoesMix = [
    "INSERT INTO mix (nome, descricao, ativo) VALUES ('Mix Power Ride', 'Sequencia completa para aula de power ride com aquecimento, forca, sprint e desaceleracao', 1)",
    "INSERT INTO mix (nome, descricao, ativo) VALUES ('Mix Sprint HIIT', 'Mix de spinning com tiros intensos, recuperacao curta e fechamento controlado', 1)",
    "INSERT INTO mix (nome, descricao, ativo) VALUES ('Mix Climb Endurance', 'Mix de subida progressiva e resistencia para aula longa de endurance', 1)",
    "INSERT INTO mix (nome, descricao, ativo) VALUES ('Mix Rhythm Recovery', 'Mix de ritmo moderado para tecnica, cadencia e recuperacao ativa', 1)",
    "INSERT INTO mix (nome, descricao, ativo) VALUES ('Mix Interval Beats', 'Mix intervalado com alternancia de tiros, subidas e recuperacao ativa', 1)",
  ];

  static const List<String> _insercoesMixMusicaPowerRide = [
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
  ];

  static const List<String> _insercoesMixMusicaSprintHiit = [
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
  ];

  static const List<String> _insercoesMixMusicaClimbEndurance = [
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
  ];

  static const List<String> _insercoesMixMusicaRhythmRecovery = [
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

  static const List<String> _insercoesMixMusicaIntervalBeats = [
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 2, 1)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 5, 2)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 8, 3)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 4, 4)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 7, 5)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 3, 6)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 6, 7)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 1, 8)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 9, 9)",
    "INSERT INTO mix_musica (mix_id, musica_id, posicao) VALUES (5, 10, 10)",
  ];

  static const List<String> _insercoesMixMusica = [
    ..._insercoesMixMusicaPowerRide,
    ..._insercoesMixMusicaSprintHiit,
    ..._insercoesMixMusicaClimbEndurance,
    ..._insercoesMixMusicaRhythmRecovery,
    ..._insercoesMixMusicaIntervalBeats,
  ];

  static const List<String> _insercoesAvaliacaoMusica = [
    """
    INSERT INTO avaliacao_musica (aluno_id, musica_id, nota, atualizado_em)
    SELECT
      aluno.id,
      musicas.musica_id,
      2 + ((aluno.id + musicas.musica_id) % 4),
      '2026-05-31T12:00:00'
    FROM aluno
    CROSS JOIN (
      SELECT DISTINCT musica_id
      FROM mix_musica
      WHERE mix_id IN (1, 2)
    ) musicas
    WHERE aluno.id BETWEEN 1 AND 10
    """,
  ];

  static const List<String> _insercoesTurma = [
    "INSERT INTO turma (nome, horario_inicio, duracao_minutos, sala_id, mix_id, ativo) VALUES ('Power Ride Manha 07h', '07:00', 50, 1, 1, 1)",
    "INSERT INTO turma (nome, horario_inicio, duracao_minutos, sala_id, mix_id, ativo) VALUES ('Cadencia Manha 09h', '09:00', 50, 1, 4, 1)",
    "INSERT INTO turma (nome, horario_inicio, duracao_minutos, sala_id, mix_id, ativo) VALUES ('Endurance Tarde 15h', '15:00', 50, 2, 3, 1)",
    "INSERT INTO turma (nome, horario_inicio, duracao_minutos, sala_id, mix_id, ativo) VALUES ('Sprint Tarde 18h30', '18:30', 45, 2, 2, 1)",
  ];

  static const List<String> _insercoesTurmaDiaSemana = [
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), 'Seg')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), 'Qua')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), 'Sex')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), 'Ter')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), 'Qui')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), 'Sab')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), 'Ter')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), 'Qui')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), 'Seg')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), 'Qua')",
    "INSERT INTO turma_dia_semana (turma_id, dia_semana) VALUES ((SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), 'Sex')",
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

  static const List<String> _insercoesAulaRealizada = [
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-01T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-04T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-06T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-08T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-11T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-13T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-15T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-18T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-20T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-22T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-25T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-27T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-05-29T07:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), '2026-05-02T09:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), '2026-05-09T09:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-05T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-07T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-12T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-14T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-19T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-21T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-26T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-05-28T15:00:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-05-01T18:30:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-05-04T18:30:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-05-06T18:30:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-05-08T18:30:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-05-11T18:30:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-05-13T18:30:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-05-15T18:30:00', 1 FROM aluno WHERE ativo = 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-02-02T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-02-04T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-02-06T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), '2026-02-07T09:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-02-10T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-02-11T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-02-13T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-02-17T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-02-18T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-02-20T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), '2026-02-21T09:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-02-25T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-03-02T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-03-04T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-03-05T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-03-06T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-03-09T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), '2026-03-14T09:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-03-17T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-03-18T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-03-20T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-03-24T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-03-25T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-03-27T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-04-01T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-04-02T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-04-03T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-04-06T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), '2026-04-11T09:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-04-14T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-04-15T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-04-17T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Endurance Tarde 15h' LIMIT 1), '2026-04-21T15:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Sprint Tarde 18h30' LIMIT 1), '2026-04-22T18:30:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Power Ride Manha 07h' LIMIT 1), '2026-04-24T07:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
    "INSERT INTO aula_realizada (aluno_id, turma_id, data, ativo) SELECT aluno_id, (SELECT id FROM turma WHERE nome = 'Cadencia Manha 09h' LIMIT 1), '2026-04-25T09:00:00', 1 FROM usuario WHERE LOWER(email) = 'aluna@gmail.com' AND aluno_id IS NOT NULL LIMIT 1",
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

  static const List<String> _insercoesCheckin = [];

  static const List<String> _insercoesFilaEspera = [];

  static const List<String> comandosGarantirMixDezMusicas = [
    ..._insercoesMixMusicaPowerRide,
  ];

  static const List<String> comandosGarantirCincoMixesDezMusicas = [
    "INSERT INTO mix (id, nome, descricao, ativo) VALUES (1, 'Mix Power Ride', 'Sequencia completa para aula de power ride com aquecimento, forca, sprint e desaceleracao', 1)",
    "INSERT INTO mix (id, nome, descricao, ativo) VALUES (2, 'Mix Sprint HIIT', 'Mix de spinning com tiros intensos, recuperacao curta e fechamento controlado', 1)",
    "INSERT INTO mix (id, nome, descricao, ativo) VALUES (3, 'Mix Climb Endurance', 'Mix de subida progressiva e resistencia para aula longa de endurance', 1)",
    "INSERT INTO mix (id, nome, descricao, ativo) VALUES (4, 'Mix Rhythm Recovery', 'Mix de ritmo moderado para tecnica, cadencia e recuperacao ativa', 1)",
    "INSERT INTO mix (id, nome, descricao, ativo) VALUES (5, 'Mix Interval Beats', 'Mix intervalado com alternancia de tiros, subidas e recuperacao ativa', 1)",
    ..._insercoesMixMusicaPowerRide,
    ..._insercoesMixMusicaSprintHiit,
    ..._insercoesMixMusicaClimbEndurance,
    ..._insercoesMixMusicaRhythmRecovery,
    ..._insercoesMixMusicaIntervalBeats,
  ];

  static const List<String> comandosNormalizarSeedsContextoReal = [];

  static const List<List<String>> comandosGarantirAulasRealizadasContexto = [
    _insercoesTurma,
    _insercoesTurmaDiaSemana,
    _insercoesAulaRealizada,
  ];

  static const List<List<String>> comandosInsercoes = [
    _insercoesFabricante,
    _insercoesCategoriaMusica,
    _insercoesTipoManutencao,
    _insercoesArtistaBanda,
    _insercoesAluno,
    _insercoesProfessora,
    _insercoesUsuario,
    _insercoesSala,
    _insercoesBike,
    _insercoesVideoAula,
    _insercoesMusica,
    _insercoesMusicaCategoria,
    _insercoesMusicaVideoAula,
    _insercoesMix,
    _insercoesMixMusica,
    _insercoesAvaliacaoMusica,
    _insercoesTurma,
    _insercoesTurmaDiaSemana,
    _insercoesGrupoAlunos,
    _insercoesGrupoAluno,
    _insercoesAulaRealizada,
    _insercoesPosicaoBike,
    _insercoesManutencao,
    _insercoesCheckin,
    _insercoesFilaEspera,
  ];
}
