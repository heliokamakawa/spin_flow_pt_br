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

    final existenteCpf = await _repositorio.buscarPorCpf(dominio.modelo.cpf);
    if (existenteCpf != null && existenteCpf.id != dominio.modelo.id) {
      return const ResultadoOperacao.falha(
        mensagemErro: 'CPF já cadastrado para outro aluno.',
      );
    }

    final existenteEmail =
        await _repositorio.buscarPorEmail(dominio.modelo.email);
    if (existenteEmail != null && existenteEmail.id != dominio.modelo.id) {
      return const ResultadoOperacao.falha(
        mensagemErro: 'E-mail já cadastrado para outro aluno.',
      );
    }

    try {
      await _repositorio.salvar(dominio.modelo);
      return const ResultadoOperacao.sucesso();
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('UNIQUE') || msg.contains('unique')) {
        return const ResultadoOperacao.falha(
          mensagemErro: 'CPF ou e-mail já cadastrado.',
        );
      }
      return ResultadoOperacao.falha(mensagemErro: msg);
    }
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
