import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/grupo_alunos.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/painel_instagram.dart';
import 'form_grupo_alunos.dart';

class ListaGruposAlunos extends StatefulWidget {
  const ListaGruposAlunos({super.key});

  @override
  State<ListaGruposAlunos> createState() => _ListaGruposAlunosState();
}

class _ListaGruposAlunosState extends State<ListaGruposAlunos> {
  final _controlador = ControladorGrupoAlunos();
  final _buscaController = TextEditingController();
  late Future<List<GrupoAlunos>> _futuro;

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

  Future<void> _abrirForm([GrupoAlunos? grupo]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormGrupoAlunos(grupo: grupo)),
    );
    if (atualizado == true) _carregar();
  }

  List<GrupoAlunos> _filtrar(List<GrupoAlunos> todos) => filtrarComPrioridade(
    todos,
    _buscaController.text,
    (g) => [g.nome, ...g.alunos.map((a) => a.nome)],
  );

  Future<void> _abrirPainelInstagram(GrupoAlunos grupo) async {
    final participantes = grupo.alunos
        .map((a) => ParticipanteInstagram(nome: a.nome, instagram: a.instagram))
        .toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PainelInstagram(participantes: participantes),
    );
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
      final resultado = await _controlador.excluir(grupo.id!);
      if (!mounted) return;
      if (!resultado.sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado.mensagemErro!), backgroundColor: CoresApp.erro),
        );
        return;
      }
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
      body: Column(
        children: [
          CampoBusca(controlador: _buscaController, dica: 'Buscar grupo ou aluno...'),
          Expanded(
            child: FutureBuilder<List<GrupoAlunos>>(
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

                final grupos = _filtrar(todos);
                if (grupos.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum resultado para "${_buscaController.text}"',
                      style: TextStyle(color: Colors.grey.shade600),
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
                              icon: const Icon(Icons.alternate_email),
                              onPressed: () => _abrirPainelInstagram(grupo),
                              tooltip: 'Instagram',
                            ),
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
          ),
        ],
      ),
    );
  }
}
