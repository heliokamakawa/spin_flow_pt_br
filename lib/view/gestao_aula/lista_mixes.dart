import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_mix.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_mix.dart';

class ListaMixes extends StatefulWidget {
  const ListaMixes({super.key});

  @override
  State<ListaMixes> createState() => _ListaMixesState();
}

class _ListaMixesState extends State<ListaMixes> {
  final _controlador = ControladorMix();
  final _buscaController = TextEditingController();
  late Future<List<Mix>> _futuro;

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

  Future<void> _abrirForm([Mix? mix]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormMix(mix: mix)),
    );
    if (atualizado == true) _carregar();
  }

  List<Mix> _filtrar(List<Mix> todos) =>
      filtrarComPrioridade(todos, _buscaController.text, (m) => [m.nome]);

  Future<void> _excluir(Mix mix) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir mix'),
        content: Text('Deseja excluir "${mix.nome}"?'),
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
    final resultado = await _controlador.excluir(mix.id!);
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
          CampoBusca(controlador: _buscaController, dica: 'Buscar mix...'),
          Expanded(
            child: FutureBuilder<List<Mix>>(
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
                        Icon(Icons.queue_music, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum mix cadastrado',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _abrirForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Novo mix'),
                        ),
                      ],
                    ),
                  );
                }
                final mixes = _filtrar(todos);
                if (mixes.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum resultado para "${_buscaController.text}"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: mixes.length,
                  itemBuilder: (_, i) => _CardMix(
                    mix: mixes[i],
                    onEditar: () => _abrirForm(mixes[i]),
                    onExcluir: () => _excluir(mixes[i]),
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

class _CardMix extends StatelessWidget {
  final Mix mix;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CardMix({
    required this.mix,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mix.ativo ? CoresApp.sucesso : CoresApp.textoFraco,
          child: const Icon(Icons.queue_music, color: Colors.white),
        ),
        title: Text(mix.nome),
        subtitle: Text(
          '${mix.musicasPreenchidas}/${Mix.totalSlots} músicas · ${mix.ativo ? "Ativo" : "Inativo"}',
        ),
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
