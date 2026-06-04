import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_turma.dart';
import 'package:spin_flow/domain/dominio/dominio_turma.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/sala.dart';
import 'package:spin_flow/domain/modelo/turma.dart';

class ControladorTurma {
  final _repositorio = RepositorioTurma();

  Future<List<Turma>> listar() => _repositorio.listar();
  Future<List<Sala>> listarSalas() => _repositorio.listarSalas();
  Future<Map<int, String>> listarProfessoras() => _repositorio.listarProfessoras();
  Future<List<Mix>> listarMixes() => _repositorio.listarMixes();

  Future<ResultadoOperacao> salvar(DominioTurma dominio) async {
    final erro = dominio.validarParaSalvar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => _repositorio.excluir(id);
}
