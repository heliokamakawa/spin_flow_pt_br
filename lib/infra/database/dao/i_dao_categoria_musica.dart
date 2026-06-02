import 'package:spin_flow/domain/modelo/categoria_musica.dart';

abstract class IDAOCategoriaMusica {
  Future<List<CategoriaMusica>> buscarTodos();
  Future<List<CategoriaMusica>> buscarAtivas();
  Future<CategoriaMusica?> buscarPorId(int id);
  Future<CategoriaMusica?> buscarPorNome(String nome);
  Future<int> salvar(CategoriaMusica categoria);
  Future<void> excluir(int id);
}
