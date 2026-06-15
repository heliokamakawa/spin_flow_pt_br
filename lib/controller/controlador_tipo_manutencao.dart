import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/domain/dominio/dominio_tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_tipo_manutencao.dart';

class ControladorTipoManutencao {
  final _repositorio = RepositorioTipoManutencao();

  Future<List<TipoManutencao>> listar() => _repositorio.listar();

  Future<ResultadoOperacao> salvar(DominioTipoManutencao dominio) async {
    final erro = dominio.validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    try {
      await _repositorio.salvar(dominio.modelo);
      return const ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }

  Future<ResultadoOperacao> excluir(int id) async {
    try {
      await _repositorio.excluir(id);
      return const ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }
}
