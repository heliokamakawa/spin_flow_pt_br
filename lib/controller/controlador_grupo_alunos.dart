import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_grupo_alunos.dart';
import 'package:spin_flow/domain/dominio/dominio_grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/grupo_alunos.dart';

class ControladorGrupoAlunos {
  final _repositorio = RepositorioGrupoAlunos();

  Future<List<GrupoAlunos>> listar() => _repositorio.listar();
  Future<List<Aluno>> listarAlunos() => _repositorio.listarAlunos();

  Future<ResultadoOperacao> salvar(DominioGrupoAlunos dominio) async {
    final erro = dominio.validarParaSalvar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => _repositorio.excluir(id);
}
