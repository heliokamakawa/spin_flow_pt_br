import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_aluno.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_aluno.dart';

class ListaAlunos extends StatefulWidget {
  const ListaAlunos({super.key});

  @override
  State<ListaAlunos> createState() => _ListaAlunosState();
}

class _ListaAlunosState extends State<ListaAlunos> {
  final _controlador = ControladorAluno();
  final _buscaController = TextEditingController();
  late Future<List<Aluno>> _alunosFuture;

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
      _alunosFuture = _controlador.listar();
    });
  }

  List<Aluno> _filtrar(List<Aluno> todos) =>
      filtrarComPrioridade(todos, _buscaController.text, (a) => [a.nome, a.email]);

  void _editar(Aluno aluno) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FormAluno(aluno: aluno)));
    _carregar();
  }

  Future<void> _excluir(int id) async {
    final resultado = await _controlador.excluir(id);
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
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: Column(
        children: [
          CampoBusca(controlador: _buscaController, dica: 'Buscar aluno ou e-mail...'),
          Expanded(
            child: FutureBuilder<List<Aluno>>(
              future: _alunosFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snapshot.data!;
                if (todos.isEmpty) {
                  return const Center(child: Text('Nenhum aluno cadastrado.'));
                }
                final alunos = _filtrar(todos);
                if (alunos.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum resultado para "${_buscaController.text}"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: alunos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final aluno = alunos[i];
                    return ListTile(
                      title: Text(aluno.nome),
                      subtitle: Text(aluno.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editar(aluno),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluir(aluno.id!),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormAluno()));
          _carregar();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
