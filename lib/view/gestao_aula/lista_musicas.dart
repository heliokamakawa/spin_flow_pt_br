import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_musica.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_musica.dart';

class ListaMusicas extends StatefulWidget {
  const ListaMusicas({super.key});

  @override
  State<ListaMusicas> createState() => _ListaMusicasState();
}

class _ListaMusicasState extends State<ListaMusicas> {
  final _controlador = ControladorMusica();
  final _buscaController = TextEditingController();
  late Future<List<Musica>> _futuro;

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

  Future<void> _abrirForm([Musica? musica]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormMusica(musica: musica)),
    );
    if (atualizado == true) _carregar();
  }

  List<Musica> _filtrar(List<Musica> todos) =>
      filtrarComPrioridade(todos, _buscaController.text, (m) => [m.nome, m.nomeArtista]);

  Future<void> _excluir(Musica musica) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir música'),
        content: Text('Deseja excluir "${musica.nome}"?'),
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
    final resultado = await _controlador.excluir(musica.id!);
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
          CampoBusca(controlador: _buscaController, dica: 'Buscar música ou artista...'),
          Expanded(
            child: FutureBuilder<List<Musica>>(
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
                        Icon(Icons.music_note, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma música cadastrada',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _abrirForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Nova música'),
                        ),
                      ],
                    ),
                  );
                }
                final musicas = _filtrar(todos);
                if (musicas.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum resultado para "${_buscaController.text}"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: musicas.length,
                  itemBuilder: (_, i) => _CardMusica(
                    musica: musicas[i],
                    onEditar: () => _abrirForm(musicas[i]),
                    onExcluir: () => _excluir(musicas[i]),
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

class _CardMusica extends StatelessWidget {
  final Musica musica;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CardMusica({
    required this.musica,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: musica.ativo ? CoresApp.sucesso : CoresApp.textoFraco,
          child: const Icon(Icons.music_note, color: Colors.white),
        ),
        title: Text(musica.nome),
        subtitle: musica.nomeArtista.isNotEmpty ? Text(musica.nomeArtista) : null,
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
