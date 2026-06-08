import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_sala.dart';
import 'package:spin_flow/domain/dominio/dominio_sala.dart';
import 'package:spin_flow/domain/modelo/sala.dart';

class ControladorSala {
  final _repositorio = RepositorioSala();

  Future<List<Sala>> listar() => _repositorio.listar();

  Future<ResultadoOperacao> salvar(DominioSala dominio) async {
    final erro = dominio.validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
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
