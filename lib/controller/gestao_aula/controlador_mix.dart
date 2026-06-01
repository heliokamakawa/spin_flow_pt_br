import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_aula/modelo_mix.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/model/servico/servico_mix.dart';

class ControladorMix {
  final ServicoMix _servico;

  ControladorMix({required ServicoMix servico}) : _servico = servico;

  Future<List<ModeloMix>> listar() => _servico.listarTodos();

  Future<List<ModeloMusica>> listarMusicasDisponiveis() =>
      _servico.listarMusicasDisponiveis();

  Future<ResultadoOperacao> salvar(ModeloMix mix) async {
    final erro = await _servico.salvar(mix);
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }

  Future<void> excluir(int id) => _servico.excluir(id);
}
