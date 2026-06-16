import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/domain/dominio/dominio_tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_tipo_manutencao.dart';

class ControladorTipoManutencao {
  final _repositorio = RepositorioTipoManutencao();

  Future<List<TipoManutencao>> listar() => _repositorio.listar();

  Future<ResultadoOperacao> salvar(TipoManutencao modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioTipoManutencao(modelo);
    final erroRegras = dominio.validarRegras();
    if (erroRegras != null) return ResultadoOperacao.falha(mensagemErro: erroRegras);
    try {
      await _repositorio.salvar(modelo);
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
