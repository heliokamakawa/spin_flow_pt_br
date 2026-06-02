import 'package:spin_flow/infra/database/sqlite/conexao.dart';
import 'package:spin_flow/infra/database/dao/i_dao_manutencao.dart';
import 'package:spin_flow/domain/modelo/manutencao.dart';

class DAOManutencaoSQLite implements IDAOManutencao {
  static const _tabela = 'manutencao';

  @override
  Future<List<Manutencao>> buscarTodos() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(_tabela, orderBy: 'data_solicitacao DESC');
    return maps.map(_mapear).toList();
  }

  @override
  Future<Manutencao?> buscarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _mapear(maps.first);
  }

  @override
  Future<void> salvar(Manutencao m) async {
    final db = await ConexaoSQLite.database;
    final estado = m.estadoOperacional;
    final dados = {
      'bike_id': m.bikeId,
      'tipo_manutencao_id': m.tipoManutencaoId,
      'data_solicitacao': m.dataSolicitacao.toIso8601String(),
      'data_realizacao': estado == EstadoOperacional.realizado
          ? DateTime.now().toIso8601String()
          : null,
      'descricao': m.descricao,
      'estado_operacional': estado.dbValue,
      'ativo': estado == EstadoOperacional.cancelado ? 0 : 1,
    };
    if (m.id != null) {
      await db.update(_tabela, dados, where: 'id = ?', whereArgs: [m.id]);
    } else {
      await db.insert(_tabela, dados);
    }
  }

  @override
  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.update(
      _tabela,
      {'ativo': 0, 'estado_operacional': 'cancelado'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Manutencao?> buscarManutencaoAtivaPorBikeId(int bikeId) async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      where:
          "bike_id = ? AND estado_operacional IN ('pendente', 'em_andamento') AND ativo = 1",
      whereArgs: [bikeId],
      orderBy: 'data_solicitacao DESC',
      limit: 1,
    );
    return maps.isEmpty ? null : _mapear(maps.first);
  }

  @override
  Future<Set<int>> buscarBikeIdsEmManutencaoAtiva() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      columns: ['bike_id'],
      where:
          "estado_operacional IN ('pendente', 'em_andamento') AND ativo = 1 AND bike_id IS NOT NULL",
    );
    return maps.map((m) => m['bike_id'] as int).toSet();
  }

  @override
  Future<Map<int, String>> buscarDescricoesAtivas() async {
    final db = await ConexaoSQLite.database;
    final maps = await db.query(
      _tabela,
      columns: ['bike_id', 'descricao'],
      where:
          "estado_operacional IN ('pendente', 'em_andamento') AND ativo = 1 AND bike_id IS NOT NULL",
    );
    return {
      for (final m in maps)
        m['bike_id'] as int: (m['descricao'] as String?) ?? '',
    };
  }

  Manutencao _mapear(Map<String, dynamic> map) => Manutencao(
    id: map['id'] as int?,
    bikeId: (map['bike_id'] as int?) ?? 0,
    tipoManutencaoId: (map['tipo_manutencao_id'] as int?) ?? 0,
    dataSolicitacao:
        DateTime.tryParse((map['data_solicitacao'] as String?) ?? '') ??
        DateTime.now(),
    descricao: (map['descricao'] as String?) ?? '',
    estadoOperacional: EstadoOperacional.fromString(
      (map['estado_operacional'] as String?) ?? 'pendente',
    ),
  );
}
