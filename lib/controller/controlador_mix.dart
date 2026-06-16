import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_mix.dart';
import 'package:spin_flow/domain/dominio/dominio_mix.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_repertorio_professora.dart';
import 'package:spin_flow/domain/modelo/musica.dart';

class ControladorMix {
  final _repositorio = RepositorioMix();

  Future<List<Mix>> listar() => _repositorio.listarTodos();
  Future<List<Musica>> listarMusicasDisponiveis() =>
      _repositorio.listarMusicasDisponiveis();

  Future<ResultadoOperacao> salvar(Mix modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioMix(modelo);
    final erroRegras = dominio.validarRegras();
    if (erroRegras != null) return ResultadoOperacao.falha(mensagemErro: erroRegras);
    await _repositorio.salvar(modelo);
    return ResultadoOperacao.sucesso();
  }

  Future<ResultadoOperacao> excluir(int id) async {
    try {
      await _repositorio.excluir(id);
      return ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<MixRepertorioProfessora?> buscarComMedias(int mixId) =>
      _repositorio.buscarMixComMedias(mixId);
}
