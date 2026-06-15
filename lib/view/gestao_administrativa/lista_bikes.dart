import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spin_flow/controller/controlador_bike.dart';
import 'package:spin_flow/domain/modelo/bike.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_bike.dart';

class ListaBikes extends StatefulWidget {
  const ListaBikes({super.key});

  @override
  State<ListaBikes> createState() => _ListaBikesState();
}

class _ListaBikesState extends State<ListaBikes> {
  final _controlador = ControladorBike();
  final _buscaController = TextEditingController();

  bool? _filtroStatus = true;
  late Future<List<Bike>> _futuro;
  Map<int, String> _nomesFabricantes = {};

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
      _futuro = _carregarDados();
    });
  }

  Future<List<Bike>> _carregarDados() async {
    final resultados = await Future.wait([
      _controlador.listar(),
      _controlador.listarFabricantes(),
    ]);
    final bikes = resultados[0] as List<Bike>;
    final fabricantes = resultados[1] as List<Fabricante>;
    _nomesFabricantes = {for (final f in fabricantes) if (f.id != null) f.id!: f.nome};
    return bikes;
  }

  Future<void> _abrirForm([Bike? bike]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormBike(bike: bike)),
    );
    if (atualizado == true) _carregar();
  }

  List<Bike> _filtrar(List<Bike> todos) {
    var resultado = todos;
    if (_filtroStatus != null) {
      resultado = resultado.where((b) => b.ativa == _filtroStatus).toList();
    }
    return filtrarComPrioridade(
      resultado,
      _buscaController.text,
      (b) => [b.nome, _nomesFabricantes[b.fabricanteId] ?? ''],
    );
  }

  Future<void> _excluir(Bike bike) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inativar bike'),
        content: Text('Deseja inativar "${bike.nome}"?'),
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
    final resultado = await _controlador.excluir(bike.id!);
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
            dica: 'Buscar por nome ou fabricante...',
          ),
          _FiltroStatus(
            valor: _filtroStatus,
            aoAlterar: (v) => setState(() => _filtroStatus = v),
          ),
          Expanded(
            child: FutureBuilder<List<Bike>>(
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
                          Icons.directions_bike_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma bike cadastrada',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _abrirForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Nova bike'),
                        ),
                      ],
                    ),
                  );
                }
                final bikes = _filtrar(todos);
                if (bikes.isEmpty) {
                  return Center(
                    child: Text(
                      _buscaController.text.isNotEmpty
                          ? 'Nenhum resultado para "${_buscaController.text}"'
                          : 'Nenhuma bike neste filtro.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: bikes.length,
                  itemBuilder: (_, i) => _CardBike(
                    bike: bikes[i],
                    nomeFabricante: _nomesFabricantes[bikes[i].fabricanteId] ?? '—',
                    onEditar: () => _abrirForm(bikes[i]),
                    onExcluir: () => _excluir(bikes[i]),
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
            label: 'Ativas',
            selecionado: valor == true,
            onTap: () => aoAlterar(valor == true ? null : true),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Inativas',
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

  const _Chip({required this.label, required this.selecionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selecionado ? Theme.of(context).primaryColor : CoresApp.textoSuave,
        fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _CardBike extends StatelessWidget {
  final Bike bike;
  final String nomeFabricante;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  static final _formatoData = DateFormat('dd/MM/yyyy', 'pt_BR');

  const _CardBike({
    required this.bike,
    required this.nomeFabricante,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: bike.ativa ? CoresApp.sucesso : CoresApp.textoFraco,
          child: const Icon(Icons.directions_bike, color: Colors.white),
        ),
        title: Text(bike.nome),
        subtitle: Text(
          '$nomeFabricante · ${_formatoData.format(bike.dataCadastro)}',
          style: const TextStyle(fontSize: 12),
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
