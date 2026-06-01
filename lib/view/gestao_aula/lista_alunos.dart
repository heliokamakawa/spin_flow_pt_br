import 'package:flutter/material.dart';
import 'package:spin_flow/model/servico/servico_aluno.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_aluno.dart';

class ListaAlunos extends StatefulWidget {
  const ListaAlunos({super.key});

  @override
  State<ListaAlunos> createState() => _ListaAlunosState();
}

class _ListaAlunosState extends State<ListaAlunos> {
  final _servico = ServicoAluno();
  late Future<List<ModeloAluno>> _alunosFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _alunosFuture = _servico.buscarTodos();
    });
  }

  void _editar(ModeloAluno aluno) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FormAluno(aluno: aluno)));
    _carregar();
  }

  void _excluir(int id) async {
    await _servico.remover(id);
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: FutureBuilder<List<ModeloAluno>>(
        future: _alunosFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final alunos = snapshot.data!;
          if (alunos.isEmpty) {
            return const Center(child: Text('Nenhum aluno cadastrado.'));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => FormAluno()));
          _carregar();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
