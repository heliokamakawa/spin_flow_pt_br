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

  Future<ResultadoOperacao> salvar(Turma modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioTurma(modelo);
    final erroRegras = dominio.validarRegras();
    if (erroRegras != null) return ResultadoOperacao.falha(mensagemErro: erroRegras);
    if (modelo.ativo) {
      final turmasExistentes = await _repositorio.listar();
      final conflito = dominio.validarConflito(turmasExistentes);
      if (conflito != null) return ResultadoOperacao.falha(mensagemErro: conflito);
    }
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
