import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_sala.dart';
import 'package:spin_flow/domain/dominio/dominio_sala.dart';
import 'package:spin_flow/domain/modelo/sala.dart';

class ControladorSala {
  RepositorioSala get _repositorio => GetIt.I<RepositorioSala>();

  Future<List<Sala>> listar() => _repositorio.listar();

  Future<ResultadoOperacao> salvar(DominioSala dominio) async {
    final erro = dominio.validarParaSalvar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => _repositorio.excluir(id);
}
