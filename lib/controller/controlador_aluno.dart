import 'package:spin_flow/infra/database/repositorio/repositorio_aluno.dart';
import 'package:spin_flow/domain/dominio/dominio_aluno.dart';

class ControladorAluno {
  final _repositorio = RepositorioAluno();

  Future<String?> salvar(DominioAluno dominio) async {
    final erro = dominio.validarParaSalvar();
    if (erro != null) return erro;
    await _repositorio.salvar(dominio.modelo);
    return null;
  }
}
