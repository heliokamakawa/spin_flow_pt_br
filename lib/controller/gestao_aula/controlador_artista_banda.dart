import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/model/gestao_aula/modelo_artista_banda.dart';
import 'package:spin_flow/model/servico/servico_artista_banda.dart';

class ControladorArtistaBanda {
  final ServicoArtistaBanda _servico;

  ControladorArtistaBanda({required ServicoArtistaBanda servico})
    : _servico = servico;

  Future<List<ModeloArtistaBanda>> listar() => _servico.listarAtivos();

  Future<ResultadoOperacao> salvar(ModeloArtistaBanda artista) async {
    final erro = await _servico.salvar(artista);
    return erro == null
        ? ResultadoOperacao.sucesso()
        : ResultadoOperacao.falha(mensagemErro: erro);
  }

  Future<void> excluir(int id) => _servico.excluir(id);
}
