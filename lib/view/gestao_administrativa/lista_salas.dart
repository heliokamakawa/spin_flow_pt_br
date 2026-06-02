import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/infra/tema/cores_app.dart';
import 'package:spin_flow/controller/controlador_sala.dart';
import '../../domain/modelo/sala.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_sala.dart';

class ListaSalas extends StatefulWidget {
  const ListaSalas({super.key});

  @override
  State<ListaSalas> createState() => _ListaSalasState();
}

class _ListaSalasState extends State<ListaSalas> {
  final _controlador = GetIt.I<ControladorSala>();
  late Future<List<Sala>> _futuro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futuro = _controlador.listar();
    });
  }

  Future<void> _abrirForm([Sala? sala]) async {
    final atualizado = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => FormSala(sala: sala)));
    if (atualizado == true) _carregar();
  }

  Future<void> _excluir(Sala sala) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir sala'),
        content: Text('Deseja desativar "${sala.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: CoresApp.erro),
            ),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _controlador.excluir(sala.id!);
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: [const AcaoSairAppBar()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Sala>>(
        future: _futuro,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final salas = snapshot.data ?? [];
          if (salas.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma sala cadastrada',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _abrirForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova sala'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: salas.length,
            itemBuilder: (_, i) => _CardSala(
              sala: salas[i],
              onEditar: () => _abrirForm(salas[i]),
              onExcluir: () => _excluir(salas[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CardSala extends StatelessWidget {
  final Sala sala;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CardSala({
    required this.sala,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sala.ativa ? CoresApp.sucesso : CoresApp.textoFraco,
          child: const Icon(Icons.meeting_room, color: Colors.white),
        ),
        title: Text(sala.nome),
        subtitle: Text(
          '${sala.numeroFilas} filas × ${sala.numeroColunas} colunas · ${sala.ativa ? "Ativa" : "Inativa"}',
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
