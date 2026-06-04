import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_mix.dart';
import 'package:spin_flow/infra/database/dao/i_dao_sala.dart';
import 'package:spin_flow/infra/database/dao/i_dao_turma.dart';
import 'package:spin_flow/infra/database/dao/i_dao_usuario.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/sala.dart';
import 'package:spin_flow/domain/modelo/turma.dart';

class RepositorioTurma {
  IDAOTurma   get _daoTurma   => GetIt.I<IDAOTurma>();
  IDAOSala    get _daoSala    => GetIt.I<IDAOSala>();
  IDAOUsuario get _daoUsuario => GetIt.I<IDAOUsuario>();
  IDAOMix     get _daoMix     => GetIt.I<IDAOMix>();

  Future<List<Turma>> listar() => _daoTurma.buscarTodos();

  Future<List<Mix>> listarMixes() async {
    final mixes = await _daoMix.buscarTodos();
    return mixes.where((m) => m.ativo).toList();
  }

  Future<List<Sala>> listarSalas() async {
    final salas = await _daoSala.buscarTodos();
    return salas.where((s) => s.ativa).toList();
  }

  /// Retorna mapa de professoraId → nome para o dropdown do FormTurma.
  Future<Map<int, String>> listarProfessoras() =>
      _daoUsuario.buscarNomesProfessoras();

  Future<void> salvar(Turma turma) => _daoTurma.salvar(turma);

  Future<void> excluir(int id) => _daoTurma.excluir(id);
}
