import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_fabricante.dart';
import 'package:spin_flow/domain/dominio/dominio_fabricante.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';

class ControladorFabricante {
  final _repositorio = RepositorioFabricante();

  Future<List<Fabricante>> listar() => _repositorio.listar();

  Future<ResultadoOperacao> salvar(DominioFabricante dominio) async {
    final erro = dominio.validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);

    final existente = await _repositorio.buscarPorNome(dominio.modelo.nome);
    if (existente != null && existente.id != dominio.modelo.id) {
      return const ResultadoOperacao.falha(
        mensagemErro: 'Já existe um fabricante com este nome.',
      );
    }

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
