import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_aluno.dart';
import 'package:spin_flow/domain/dominio/dominio_aluno.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';

class ControladorAluno {
  final _repositorio = RepositorioAluno();

  Future<List<Aluno>> listar() => _repositorio.buscarTodos();

  Future<ResultadoOperacao> salvar(Aluno modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioAluno(modelo);
    final erroRegras = dominio.validarRegras();
    if (erroRegras != null) return ResultadoOperacao.falha(mensagemErro: erroRegras);

    final existenteCpf = await _repositorio.buscarPorCpf(modelo.cpf);
    if (existenteCpf != null && existenteCpf.id != modelo.id) {
      return const ResultadoOperacao.falha(
        mensagemErro: 'CPF já cadastrado para outro aluno.',
      );
    }

    final existenteEmail = await _repositorio.buscarPorEmail(modelo.email);
    if (existenteEmail != null && existenteEmail.id != modelo.id) {
      return const ResultadoOperacao.falha(
        mensagemErro: 'E-mail já cadastrado para outro aluno.',
      );
    }

    try {
      await _repositorio.salvar(modelo);
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
