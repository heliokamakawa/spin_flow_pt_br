import 'package:spin_flow/model/gestao_aula/modelo_categoria_musica.dart';

abstract class IDAOCategoriaMusica {
  Future<List<ModeloCategoriaMusica>> buscarTodos();
  Future<List<ModeloCategoriaMusica>> buscarAtivas();
  Future<ModeloCategoriaMusica?> buscarPorId(int id);
  Future<ModeloCategoriaMusica?> buscarPorNome(String nome);
  Future<int> salvar(ModeloCategoriaMusica categoria);
  Future<void> excluir(int id);
}
