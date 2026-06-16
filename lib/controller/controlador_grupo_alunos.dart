import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_grupo_alunos.dart';
import 'package:spin_flow/domain/dominio/dominio_grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/grupo_alunos.dart';

class ControladorGrupoAlunos {
  final _repositorio = RepositorioGrupoAlunos();

  Future<List<GrupoAlunos>> listar() => _repositorio.listar();
  Future<List<Aluno>> listarAlunos() => _repositorio.listarAlunos();

  Future<ResultadoOperacao> salvar(GrupoAlunos modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioGrupoAlunos(modelo);
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
