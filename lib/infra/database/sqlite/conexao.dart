import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'script.dart';
import 'script_dinamicas.dart';

class ConexaoSQLite {
  static Database? _database;
  static Future<Database>? _iniciando;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _iniciando ??= _inicializarBanco();
    _database = await _iniciando!;
    return _database!;
  }

  static Future<Database> _inicializarBanco() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (kIsWeb) {
      path = 'spin_flow.db';
    } else {
      String databasesPath = await databaseFactory.getDatabasesPath();
      path = join(databasesPath, 'spin_flow.db');
    }
    await databaseFactory.deleteDatabase(path);
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 14,
        onCreate: _criarTabelas,
        onUpgrade: _atualizarBanco,
      ),
    );
  }

  static Future<void> _criarTabelas(Database db, int version) async {
    for (String comando in ScriptSQLite.comandosCriarTabelas) {
      await db.execute(comando);
    }
    for (List<String> insercoes in ScriptSQLite.comandosInsercoes) {
      for (String comando in insercoes) {
        await db.execute(comando);
      }
    }
    for (final comando in ScriptDinamicasSQLite.comandosInsercoes(
      DateTime.now(),
    )) {
      await db.execute(comando);
    }
  }

  static Future<void> _atualizarBanco(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(ScriptSQLite.criarTabelaAvaliacaoMusicaSeNaoExistir);
    }
    if (oldVersion < 3) {
      await db.execute(ScriptSQLite.criarTabelaMixMusicaSeNaoExistir);
      for (final comando in ScriptSQLite.comandosGarantirMixDezMusicas) {
        await db.execute(comando);
      }
    }
    if (oldVersion < 4) {
      for (final comando in ScriptSQLite.comandosNormalizarSeedsContextoReal) {
        await db.execute(comando);
      }
    }
    await _removerDiasSemanaTurma(db);
    if (oldVersion < 5) {
      await _normalizarAulasSeed(db);
    }
    if (oldVersion < 6) {
      await _vincularUsuariosPerfis(db);
    }
    if (oldVersion < 10) {
      await _vincularUsuariosAoDominio(db);
    }
    if (oldVersion < 11) {
      await _garantirCincoMixesDezMusicas(db);
    }
    if (oldVersion < 12) {
      await db.execute(ScriptSQLite.criarTabelaAulaRealizadaSeNaoExistir);
    }
    if (oldVersion < 13) {
      await _garantirAulasRealizadasContexto(db);
    }
    if (oldVersion < 14) {
      await _removerDiasSemanaTurma(db);
    }
  }

  static Future<void> _normalizarAulasSeed(Database db) async {
    await db.delete('fila_espera_checkin');
    await db.delete('checkin');
    await db.delete('turma_dia_semana');
    await db.delete('turma');

    for (final comando in ScriptDinamicasSQLite.comandosInsercoes(
      DateTime.now(),
    )) {
      await db.execute(comando);
    }
  }

  static Future<void> _vincularUsuariosPerfis(Database db) async {
    await db.execute(ScriptSQLite.criarTabelaProfessoraSeNaoExistir);
    await _garantirLinhasProfessora(db);
  }

  static Future<void> _garantirCincoMixesDezMusicas(Database db) async {
    await db.execute(ScriptSQLite.criarTabelaMixMusicaSeNaoExistir);
    for (final comando in ScriptSQLite.comandosGarantirCincoMixesDezMusicas) {
      await db.execute(comando);
    }
  }

  static Future<void> _garantirAulasRealizadasContexto(Database db) async {
    await db.execute(ScriptSQLite.criarTabelaAulaRealizadaSeNaoExistir);
    for (final grupo in ScriptSQLite.comandosGarantirAulasRealizadasContexto) {
      for (final comando in grupo) {
        await db.execute(comando);
      }
    }
  }

  static Future<void> _removerDiasSemanaTurma(Database db) async {
    final possuiDiasSemana = await _colunaExiste(
      db,
      tabela: 'turma',
      coluna: 'dias_semana',
    );
    if (!possuiDiasSemana) return;

    await db.execute('DROP TABLE IF EXISTS turma_sem_dias_semana');
    await db.execute('''
      CREATE TABLE turma_sem_dias_semana (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT NOT NULL,
        horario_inicio TEXT NOT NULL,
        duracao_minutos INTEGER NOT NULL,
        sala_id INTEGER,
        ativo INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      INSERT INTO turma_sem_dias_semana (
        id,
        nome,
        descricao,
        horario_inicio,
        duracao_minutos,
        sala_id,
        ativo
      )
      SELECT
        id,
        nome,
        descricao,
        horario_inicio,
        duracao_minutos,
        sala_id,
        ativo
      FROM turma
    ''');
    await db.execute('DROP TABLE turma');
    await db.execute('ALTER TABLE turma_sem_dias_semana RENAME TO turma');
  }

  static Future<void> _vincularUsuariosAoDominio(Database db) async {
    await db.execute(ScriptSQLite.criarTabelaProfessoraSeNaoExistir);

    final possuiAlunoIdUsuario = await _colunaExiste(
      db,
      tabela: 'usuario',
      coluna: 'aluno_id',
    );
    if (!possuiAlunoIdUsuario) {
      await db.execute(ScriptSQLite.adicionarAlunoIdUsuario);
    }

    final possuiProfessoraIdUsuario = await _colunaExiste(
      db,
      tabela: 'usuario',
      coluna: 'professora_id',
    );
    if (!possuiProfessoraIdUsuario) {
      await db.execute(ScriptSQLite.adicionarProfessoraIdUsuario);
    }

    await _garantirLinhasProfessora(db);

    final professoraPossuiUsuarioId = await _colunaExiste(
      db,
      tabela: 'professora',
      coluna: 'usuario_id',
    );

    if (professoraPossuiUsuarioId) {
      await db.execute('''
        UPDATE usuario
        SET professora_id = (
          SELECT professora.id
          FROM professora
          WHERE professora.usuario_id = usuario.id
          LIMIT 1
        )
        WHERE LOWER(email) IN (
          'professora@gmail.com',
          'marina.torres@pulsestudio.com.br',
          'paula.nogueira@pulsestudio.com.br',
          'ricardo.mendes@pulsestudio.com.br'
        )
      ''');
    } else {
      await db.execute('''
        UPDATE usuario
        SET professora_id = CASE LOWER(email)
          WHEN 'professora@gmail.com' THEN 1
          WHEN 'marina.torres@pulsestudio.com.br' THEN 2
          WHEN 'paula.nogueira@pulsestudio.com.br' THEN 3
          WHEN 'ricardo.mendes@pulsestudio.com.br' THEN 4
          ELSE professora_id
        END
        WHERE LOWER(email) IN (
          'professora@gmail.com',
          'marina.torres@pulsestudio.com.br',
          'paula.nogueira@pulsestudio.com.br',
          'ricardo.mendes@pulsestudio.com.br'
        )
      ''');
    }

    await db.execute('''
      UPDATE usuario
      SET aluno_id = (
        SELECT aluno.id
        FROM aluno
        WHERE LOWER(aluno.email) = LOWER(usuario.email)
        LIMIT 1
      )
      WHERE EXISTS (
        SELECT 1
        FROM aluno
        WHERE LOWER(aluno.email) = LOWER(usuario.email)
      )
    ''');
  }

  static Future<void> _garantirLinhasProfessora(Database db) async {
    final possuiUsuarioId = await _colunaExiste(
      db,
      tabela: 'professora',
      coluna: 'usuario_id',
    );

    if (possuiUsuarioId) {
      await db.execute('''
        INSERT OR IGNORE INTO professora (usuario_id, ativo)
        SELECT id, 1
        FROM usuario
        WHERE LOWER(email) IN (
          'professora@gmail.com',
          'marina.torres@pulsestudio.com.br',
          'paula.nogueira@pulsestudio.com.br',
          'ricardo.mendes@pulsestudio.com.br'
        )
      ''');
      return;
    }

    for (var id = 1; id <= 4; id++) {
      await db.execute(
        'INSERT OR IGNORE INTO professora (id, ativo) VALUES ($id, 1)',
      );
    }
  }

  static Future<bool> _colunaExiste(
    Database db, {
    required String tabela,
    required String coluna,
  }) async {
    final colunas = await db.rawQuery('PRAGMA table_info($tabela)');
    return colunas.any((mapa) => mapa['name'] == coluna);
  }

  static Future<void> fecharConexao() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
