import 'package:spin_flow/model/dao/i_dao_sala.dart';
import 'package:spin_flow/model/dao/i_dao_turma.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';

class ServicoTurma {
  final IDAOTurma daoTurma;
  final IDAOSala daoSala;

  const ServicoTurma({required this.daoTurma, required this.daoSala});

  Future<List<ModeloTurma>> listar() => daoTurma.buscarTodos();

  Future<List<ModeloSala>> listarSalas() async {
    final salas = await daoSala.buscarTodos();
    return salas.where((sala) => sala.ativa).toList();
  }

  Future<String?> salvar(ModeloTurma turma) async {
    final erro = turma.validar();
    if (erro != null) return erro;

    try {
      await daoTurma.salvar(turma);
      return null;
    } catch (e) {
      final mensagem = e.toString();
      if (mensagem.contains('Conflito de horario')) {
        return 'Ja existe turma ativa nesta sala, dia e horario.';
      }
      return 'Erro ao salvar turma.';
    }
  }

  Future<void> excluir(int id) => daoTurma.excluir(id);
}
