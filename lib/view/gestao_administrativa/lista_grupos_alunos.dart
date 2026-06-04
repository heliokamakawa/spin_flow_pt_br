import 'package:flutter/material.dart';
import 'package:spin_flow/infra/config/cores_app.dart';
import 'package:spin_flow/controller/controlador_grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/grupo_alunos.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_grupo_alunos.dart';

class ListaGruposAlunos extends StatefulWidget {
  const ListaGruposAlunos({super.key});

  @override
  State<ListaGruposAlunos> createState() => _ListaGruposAlunosState();
}

class _ListaGruposAlunosState extends State<ListaGruposAlunos> {
  final _controlador = ControladorGrupoAlunos();
  late Future<List<GrupoAlunos>> _futuro;

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

  Future<void> _abrirForm([GrupoAlunos? grupo]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormGrupoAlunos(grupo: grupo)),
    );
    if (atualizado == true) _carregar();
  }

  Future<void> _excluir(GrupoAlunos grupo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir grupo'),
        content: Text('Deseja desativar "${grupo.nome}"?'),
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
      await _controlador.excluir(grupo.id!);
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
      body: FutureBuilder<List<GrupoAlunos>>(
        future: _futuro,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final grupos = snapshot.data ?? [];
          if (grupos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_work_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum grupo cadastrado',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _abrirForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo grupo'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: grupos.length,
            itemBuilder: (_, i) {
              final grupo = grupos[i];
              final nomesAlunos = grupo.alunos
                  .map((aluno) => aluno.nome)
                  .take(3)
                  .join(', ');
              final complemento = grupo.alunos.length > 3
                  ? ' +${grupo.alunos.length - 3}'
                  : '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: grupo.ativo
                        ? CoresApp.sucesso
                        : CoresApp.textoFraco,
                    child: const Icon(Icons.group_work, color: Colors.white),
                  ),
                  title: Text(grupo.nome),
                  subtitle: Text(
                    '${grupo.alunos.length} aluno(s)'
                    '${nomesAlunos.isEmpty ? '' : ': $nomesAlunos$complemento'}\n'
                    '${grupo.ativo ? "Ativo" : "Inativo"}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  onTap: () => _abrirForm(grupo),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: CoresApp.alerta),
                        onPressed: () => _abrirForm(grupo),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: CoresApp.erro),
                        onPressed: () => _excluir(grupo),
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
