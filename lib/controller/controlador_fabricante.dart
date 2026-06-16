import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_fabricante.dart';
import 'package:spin_flow/domain/dominio/dominio_fabricante.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';

class ControladorFabricante {
  final _repositorio = RepositorioFabricante();

  Future<List<Fabricante>> listar() => _repositorio.listar();

  Future<ResultadoOperacao> salvar(Fabricante modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioFabricante(modelo);
    final erroRegras = dominio.validarRegras();
    if (erroRegras != null) return ResultadoOperacao.falha(mensagemErro: erroRegras);

    final existente = await _repositorio.buscarPorNome(modelo.nome);
    if (existente != null && existente.id != modelo.id) {
      return const ResultadoOperacao.falha(
        mensagemErro: 'Já existe um fabricante com este nome.',
      );
    }

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
