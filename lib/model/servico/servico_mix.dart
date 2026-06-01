import 'package:spin_flow/model/dao/i_dao_mix.dart';
import 'package:spin_flow/model/dao/i_dao_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_mix.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';

class ServicoMix {
  final IDAOMix _daoMix;
  final IDAOMusica _daoMusica;

  ServicoMix({required IDAOMix daoMix, required IDAOMusica daoMusica})
    : _daoMix = daoMix,
      _daoMusica = daoMusica;

  Future<List<ModeloMix>> listarTodos() => _daoMix.buscarTodos();

  Future<List<ModeloMusica>> listarMusicasDisponiveis() =>
      _daoMusica.buscarAtivas();

  Future<String?> salvar(ModeloMix mix) async {
    if (mix.nome.trim().isEmpty) return 'Nome é obrigatório.';
    if (mix.musicasPreenchidas == 0) return 'Adicione pelo menos uma música.';
    await _daoMix.salvar(mix);
    return null;
  }

  Future<void> excluir(int id) => _daoMix.excluir(id);
}
