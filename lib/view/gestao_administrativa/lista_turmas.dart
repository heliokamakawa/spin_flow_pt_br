import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_turma.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/gestao_administrativa/form_turma.dart';

class ListaTurmas extends StatefulWidget {
  const ListaTurmas({super.key});

  @override
  State<ListaTurmas> createState() => _ListaTurmasState();
}

class _ListaTurmasState extends State<ListaTurmas> {
  final _controlador = GetIt.I<ControladorTurma>();
  late Future<List<ModeloTurma>> _futuro;

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

  Future<void> _abrirForm([ModeloTurma? turma]) async {
    final atualizado = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => FormTurma(turma: turma)));
    if (atualizado == true) _carregar();
  }

  Future<void> _excluir(ModeloTurma turma) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir turma'),
        content: Text('Deseja desativar "${turma.nome}"?'),
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
      await _controlador.excluir(turma.id!);
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turmas'),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        actions: [const AcaoSairAppBar()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ModeloTurma>>(
        future: _futuro,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final turmas = snapshot.data ?? [];
          if (turmas.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma turma cadastrada',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _abrirForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova turma'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: turmas.length,
            itemBuilder: (_, i) {
              final turma = turmas[i];
              final dias = turma.diasSemana.map((dia) => dia.rotulo).join(', ');
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: turma.ativo
                        ? CoresApp.sucesso
                        : CoresApp.textoFraco,
                    child: const Icon(Icons.groups, color: Colors.white),
                  ),
                  title: Text(turma.nome),
                  subtitle: Text(
                    '$dias - ${turma.horarioInicio} '
                    '(${turma.duracaoMinutos} min)\n'
                    '${turma.ativo ? "Ativa" : "Inativa"}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  onTap: () => _abrirForm(turma),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: CoresApp.alerta),
                        onPressed: () => _abrirForm(turma),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: CoresApp.erro),
                        onPressed: () => _excluir(turma),
                        tooltip: 'Excluir',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
