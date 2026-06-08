import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_artista_banda.dart';
import 'package:spin_flow/domain/modelo/artista_banda.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_artista_banda.dart';

class ListaArtistasBandas extends StatefulWidget {
  const ListaArtistasBandas({super.key});

  @override
  State<ListaArtistasBandas> createState() => _ListaArtistasBandasState();
}

class _ListaArtistasBandasState extends State<ListaArtistasBandas> {
  final _controlador = ControladorArtistaBanda();
  final _buscaController = TextEditingController();
  late Future<List<ArtistaBanda>> _futuro;

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() => setState(() {}));
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _carregar() {
    setState(() {
      _futuro = _controlador.listar();
    });
  }

  Future<void> _abrirForm([ArtistaBanda? artista]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormArtistaBanda(artista: artista)),
    );
    if (atualizado == true) _carregar();
  }

  List<ArtistaBanda> _filtrar(List<ArtistaBanda> todos) =>
      filtrarComPrioridade(todos, _buscaController.text, (a) => [a.nome, a.descricao]);

  Future<void> _excluir(ArtistaBanda artista) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir artista/banda'),
        content: Text('Deseja excluir "${artista.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: CoresApp.erro)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final resultado = await _controlador.excluir(artista.id!);
    if (!mounted) return;
    if (!resultado.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensagemErro!),
          backgroundColor: CoresApp.erro,
        ),
      );
      return;
    }
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CampoBusca(controlador: _buscaController, dica: 'Buscar artista ou banda...'),
          Expanded(
            child: FutureBuilder<List<ArtistaBanda>>(
              future: _futuro,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snapshot.data ?? [];
                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_none, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum artista ou banda cadastrado',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _abrirForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Novo artista'),
                        ),
                      ],
                    ),
                  );
                }
                final artistas = _filtrar(todos);
                if (artistas.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum resultado para "${_buscaController.text}"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: artistas.length,
                  itemBuilder: (_, i) => _CardArtistaBanda(
                    artista: artistas[i],
                    onEditar: () => _abrirForm(artistas[i]),
                    onExcluir: () => _excluir(artistas[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CardArtistaBanda extends StatelessWidget {
  final ArtistaBanda artista;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CardArtistaBanda({
    required this.artista,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: artista.ativo ? CoresApp.sucesso : CoresApp.textoFraco,
          child: const Icon(Icons.mic, color: Colors.white),
        ),
        title: Text(artista.nome),
        subtitle: artista.descricao.isNotEmpty ? Text(artista.descricao) : null,
        onTap: onEditar,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: CoresApp.alerta),
              onPressed: onEditar,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: CoresApp.erro),
              onPressed: onExcluir,
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
