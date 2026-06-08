import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_aluno.dart';
import 'package:spin_flow/domain/dominio/dominio_aluno.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';

class ControladorAluno {
  final _repositorio = RepositorioAluno();

  Future<List<Aluno>> listar() => _repositorio.buscarTodos();

  Future<ResultadoOperacao> salvar(DominioAluno dominio) async {
    final erro = dominio.validar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return const ResultadoOperacao.sucesso();
  }

  Future<ResultadoOperacao> excluir(int id) async {
    try {
      await _repositorio.remover(id);
      return const ResultadoOperacao.sucesso();
    } catch (e) {
      return ResultadoOperacao.falha(mensagemErro: e.toString());
    }
  }
}
