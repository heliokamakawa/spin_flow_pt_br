import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_manutencao.dart';
import 'package:spin_flow/domain/dominio/dominio_manutencao.dart';
import 'package:spin_flow/domain/modelo/bike.dart';
import 'package:spin_flow/domain/modelo/manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';

class ControladorManutencao {
  final _repositorio = RepositorioManutencao();

  Future<List<Manutencao>> listar() => _repositorio.listar();
  Future<List<Bike>> listarBikes() => _repositorio.listarBikes();
  Future<List<TipoManutencao>> listarTipos() => _repositorio.listarTipos();

  Future<ResultadoOperacao> salvar(Manutencao modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioManutencao(modelo);
    final erroRegras = dominio.validarRegras();
    if (erroRegras != null) return ResultadoOperacao.falha(mensagemErro: erroRegras);
    await _repositorio.salvar(modelo);
    return const ResultadoOperacao.sucesso();
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
