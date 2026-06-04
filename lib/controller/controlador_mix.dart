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

  Future<ResultadoOperacao> salvar(DominioMix dominio) async {
    final erro = dominio.validarParaSalvar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => _repositorio.excluir(id);

  Future<MixRepertorioProfessora?> buscarComMedias(int mixId) =>
      _repositorio.buscarMixComMedias(mixId);
}
