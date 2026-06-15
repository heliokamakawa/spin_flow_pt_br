import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_fabricante.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_fabricante.dart';

class ListaFabricantes extends StatefulWidget {
  const ListaFabricantes({super.key});

  @override
  State<ListaFabricantes> createState() => _ListaFabricantesState();
}

class _ListaFabricantesState extends State<ListaFabricantes> {
  final _controlador = ControladorFabricante();
  final _buscaController = TextEditingController();

  // null = todos, true = apenas ativos, false = apenas inativos
  bool? _filtroStatus = true;
  late Future<List<Fabricante>> _futuro;

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

  Future<void> _abrirForm([Fabricante? fabricante]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormFabricante(fabricante: fabricante),
      ),
    );
    if (atualizado == true) _carregar();
  }

  List<Fabricante> _filtrar(List<Fabricante> todos) {
    var resultado = todos;

    if (_filtroStatus != null) {
      resultado = resultado.where((f) => f.ativo == _filtroStatus).toList();
    }

    return filtrarComPrioridade(
      resultado,
      _buscaController.text,
      (f) => [f.nome, f.nomeContatoPrincipal, f.emailContato, f.telefoneContato],
    );
  }

  Future<void> _excluir(Fabricante fabricante) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inativar fabricante'),
        content: Text('Deseja inativar "${fabricante.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Inativar',
              style: TextStyle(color: CoresApp.erro),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final resultado = await _controlador.excluir(fabricante.id!);
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
          CampoBusca(
            controlador: _buscaController,
            dica: 'Buscar por nome ou contato...',
          ),
          _FiltroStatus(
            valor: _filtroStatus,
            aoAlterar: (v) => setState(() => _filtroStatus = v),
          ),
          Expanded(
            child: FutureBuilder<List<Fabricante>>(
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
                        Icon(
                          Icons.precision_manufacturing_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum fabricante cadastrado',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _abrirForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Novo fabricante'),
                        ),
                      ],
                    ),
                  );
                }
                final fabricantes = _filtrar(todos);
                if (fabricantes.isEmpty) {
                  return Center(
                    child: Text(
                      _buscaController.text.isNotEmpty
                          ? 'Nenhum resultado para "${_buscaController.text}"'
                          : 'Nenhum fabricante neste filtro.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: fabricantes.length,
                  itemBuilder: (_, i) => _CardFabricante(
                    fabricante: fabricantes[i],
                    onEditar: () => _abrirForm(fabricantes[i]),
                    onExcluir: () => _excluir(fabricantes[i]),
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

class _FiltroStatus extends StatelessWidget {
  final bool? valor;
  final void Function(bool?) aoAlterar;

  const _FiltroStatus({required this.valor, required this.aoAlterar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          _Chip(
            label: 'Ativos',
            selecionado: valor == true,
            onTap: () => aoAlterar(valor == true ? null : true),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Inativos',
            selecionado: valor == false,
            onTap: () => aoAlterar(valor == false ? null : false),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selecionado
            ? Theme.of(context).primaryColor
            : CoresApp.textoSuave,
        fontWeight:
            selecionado ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _CardFabricante extends StatelessWidget {
  final Fabricante fabricante;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CardFabricante({
    required this.fabricante,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final temContato = fabricante.emailContato.isNotEmpty ||
        fabricante.telefoneContato.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              fabricante.ativo ? CoresApp.sucesso : CoresApp.textoFraco,
          child: const Icon(
            Icons.precision_manufacturing,
            color: Colors.white,
          ),
        ),
        title: Text(fabricante.nome),
        subtitle: temContato
            ? Text(
                [
                  if (fabricante.emailContato.isNotEmpty)
                    fabricante.emailContato,
                  if (fabricante.telefoneContato.isNotEmpty)
                    fabricante.telefoneContato,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              )
            : fabricante.ativo
                ? null
                : const Text(
                    'Inativo',
                    style: TextStyle(
                      fontSize: 12,
                      color: CoresApp.textoFraco,
                    ),
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
              icon: const Icon(Icons.block, color: CoresApp.erro),
              onPressed: onExcluir,
              tooltip: 'Inativar',
            ),
          ],
        ),
      ),
    );
  }
}
