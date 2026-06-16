import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_sala.dart';
import 'package:spin_flow/domain/dominio/dominio_sala.dart';
import 'package:spin_flow/domain/modelo/sala.dart';

class ControladorSala {
  final _repositorio = RepositorioSala();

  Future<List<Sala>> listar() => _repositorio.listar();

  Future<ResultadoOperacao> salvar(Sala modelo) async {
    final erroDados = modelo.validar();
    if (erroDados != null) return ResultadoOperacao.falha(mensagemErro: erroDados);

    final dominio = DominioSala(modelo);
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
