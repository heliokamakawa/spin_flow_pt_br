import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/resultado_operacao.dart';
import 'package:spin_flow/infra/database/repositorio/repositorio_manutencao.dart';
import 'package:spin_flow/domain/dominio/dominio_manutencao.dart';
import 'package:spin_flow/domain/modelo/bike.dart';
import 'package:spin_flow/domain/modelo/manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';

class ControladorManutencao {
  RepositorioManutencao get _repositorio => GetIt.I<RepositorioManutencao>();

  Future<List<Manutencao>> listar() => _repositorio.listar();
  Future<List<Bike>> listarBikes() => _repositorio.listarBikes();
  Future<List<TipoManutencao>> listarTipos() => _repositorio.listarTipos();

  Future<ResultadoOperacao> salvar(DominioManutencao dominio) async {
    final erro = dominio.validarParaSalvar();
    if (erro != null) return ResultadoOperacao.falha(mensagemErro: erro);
    await _repositorio.salvar(dominio.modelo);
    return const ResultadoOperacao.sucesso();
  }

  Future<void> excluir(int id) => _repositorio.excluir(id);
}
