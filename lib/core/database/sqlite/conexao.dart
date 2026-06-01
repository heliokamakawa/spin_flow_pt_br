import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'script.dart';

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
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
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
    for (final comando in ScriptSQLite.comandosInsercoesDinamicas(
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
  }

  static Future<void> fecharConexao() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
