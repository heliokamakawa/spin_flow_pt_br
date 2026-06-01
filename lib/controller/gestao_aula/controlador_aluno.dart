import 'package:spin_flow/model/modelo/modelo_aluno.dart';
import 'package:spin_flow/model/servico/servico_aluno.dart';

class ControladorAluno {
  final ServicoAluno _servicoAluno;
  ControladorAluno({ServicoAluno? servicoAluno})
    : _servicoAluno = servicoAluno ?? ServicoAluno();

  Future<String?> salvarAluno(ModeloAluno aluno) async {
    final erro = aluno.validar();
    if (erro != null) return erro;
    await _servicoAluno.salvar(aluno);
    return null;
  }
}
