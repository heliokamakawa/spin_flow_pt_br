import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/domain/dominio/dominio_bike.dart';
import 'package:spin_flow/domain/modelo/bike.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';
import 'package:spin_flow/domain/modelo/posicao_bike.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_bike.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_fabricante.dart';

class ControladorBike {
  final _repositorio = RepositorioBike();
  final _repositorioFabricante = RepositorioFabricante();

  Future<List<Bike>> listar() => _repositorio.listar();

  Future<List<Fabricante>> listarFabricantes() =>
      _repositorioFabricante.listar();

  Future<List<PosicaoBike>> listarPosicoes() => _repositorio.listarPosicoes();

  Future<PosicaoBike?> buscarPosicaoDaBike(int bikeId) =>
      _repositorio.buscarPosicaoDaBike(bikeId);

  Future<ResultadoOperacao> salvar(
    DominioBike dominio, {
    PosicaoBike? posicao,
    bool gerenciarPosicao = false,
  }) async {
    final erro = dominio.validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);

    final existente = await _repositorio.buscarPorNome(dominio.modelo.nome);
    if (existente != null && existente.id != dominio.modelo.id) {
      return const ResultadoOperacao.falha(
        mensagemErro: 'Já existe uma bike com este nome.',
      );
    }

    final bikeId = await _repositorio.salvar(dominio.modelo);

    if (!gerenciarPosicao) return const ResultadoOperacao.sucesso();

    final posAtual = await _repositorio.buscarPosicaoDaBike(bikeId);

    final mesmaPos = posAtual != null &&
        posicao != null &&
        posAtual.fila == posicao.fila &&
        posAtual.coluna == posicao.coluna;
    if (mesmaPos) return const ResultadoOperacao.sucesso();

    if (posAtual != null) {
      await _repositorio.atribuirPosicao(posAtual.fila, posAtual.coluna, null);
    }

    if (posicao != null) {
      final posicoes = await _repositorio.listarPosicoes();
      final posAlvo = posicoes
          .where((p) => p.fila == posicao.fila && p.coluna == posicao.coluna)
          .firstOrNull;
      if (posAlvo == null) {
        return const ResultadoOperacao.falha(
          mensagemErro: 'Posição não encontrada na grade.',
        );
      }
      if (posAlvo.bikeId != null && posAlvo.bikeId != bikeId) {
        return const ResultadoOperacao.falha(
          mensagemErro: 'Esta posição já está ocupada por outra bike.',
        );
      }
      await _repositorio.atribuirPosicao(posicao.fila, posicao.coluna, bikeId);
    }

    return const ResultadoOperacao.sucesso();
  }

  Future<ResultadoOperacao> excluir(int id) async {
    try {
      final posAtual = await _repositorio.buscarPosicaoDaBike(id);
      if (posAtual != null) {
        await _repositorio.atribuirPosicao(posAtual.fila, posAtual.coluna, null);
      }
      await _repositorio.excluir(id);
      return const ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }
}
