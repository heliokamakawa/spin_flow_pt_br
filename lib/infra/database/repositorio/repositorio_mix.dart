import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/database/dao/i_dao_mix.dart';
import 'package:spin_flow/infra/database/dao/i_dao_musica.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_repertorio_professora.dart';
import 'package:spin_flow/domain/modelo/musica.dart';

class RepositorioMix {
  IDAOMix    get _daoMix    => GetIt.I<IDAOMix>();
  IDAOMusica get _daoMusica => GetIt.I<IDAOMusica>();

  Future<List<Mix>>    listarTodos()             => _daoMix.buscarTodos();
  Future<List<Musica>> listarMusicasDisponiveis() => _daoMusica.buscarAtivas();

  Future<void> salvar(Mix mix) => _daoMix.salvar(mix);
  Future<void> excluir(int id) => _daoMix.excluir(id);

  Future<MixRepertorioProfessora?> buscarMixComMedias(int mixId) =>
      _daoMix.buscarMixComMediasPorId(mixId);
}
