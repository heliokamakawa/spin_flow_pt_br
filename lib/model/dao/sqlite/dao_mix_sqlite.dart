import 'package:spin_flow/core/database/sqlite/conexao.dart';
import 'package:spin_flow/model/dao/i_dao_mix.dart';
import 'package:spin_flow/model/gestao_aula/modelo_mix.dart';

class DAOMixSQLite implements IDAOMix {
  static const _tabela = 'mix';
  static const _tabelaMixMusica = 'mix_musica';

  @override
  Future<List<ModeloMix>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'ativo = 1', orderBy: 'nome');
    final List<ModeloMix> lista = [];
    for (final map in maps) {
      lista.add(await _mapParaModelo(map));
    }
    return lista;
  }

  @override
  Future<ModeloMix?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _mapParaModelo(maps.first);
  }

  @override
  Future<int> salvar(ModeloMix mix) async {
    final db = await ConexaoSQLite.database;
    final dados = {
      'nome': mix.nome,
      'musica_ids': '[]',
      'descricao': mix.descricao,
      'ativo': mix.ativo ? 1 : 0,
    };

    late int mixId;
    if (mix.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [mix.id]);
      mixId = mix.id!;
    } else {
      mixId = await db.insert(_tabela, dados);
    }

    await db.transaction((txn) async {
      await txn.delete(
        _tabelaMixMusica,
        where: 'mix_id = ?',
        whereArgs: [mixId],
      );
      for (int i = 0; i < mix.posicoes.length; i++) {
        final musicaId = mix.posicoes[i];
        if (musicaId != null) {
          await txn.insert(_tabelaMixMusica, {
            'mix_id': mixId,
            'musica_id': musicaId,
            'posicao': i + 1,
          });
        }
      }
    });

    return mixId;
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(_tabela, {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<ModeloMix> _mapParaModelo(Map<String, dynamic> map) async {
    final mixId = map['id'] as int?;
    final posicoes = List<int?>.filled(ModeloMix.totalSlots, null);

    if (mixId != null) {
      final db = await ConexaoSQLite.database;
      final slots = await db.query(
        _tabelaMixMusica,
        where: 'mix_id = ?',
        whereArgs: [mixId],
        orderBy: 'posicao',
      );
      for (final slot in slots) {
        final pos = (slot['posicao'] as int?) ?? 0;
        final musicaId = slot['musica_id'] as int?;
        if (pos >= 1 && pos <= ModeloMix.totalSlots && musicaId != null) {
          posicoes[pos - 1] = musicaId;
        }
      }
    }

    return ModeloMix(
      id: mixId,
      nome: (map['nome'] as String?) ?? '',
      descricao: (map['descricao'] as String?) ?? '',
      posicoes: posicoes,
      ativo: ((map['ativo'] as int?) ?? 1) == 1,
    );
  }
}
