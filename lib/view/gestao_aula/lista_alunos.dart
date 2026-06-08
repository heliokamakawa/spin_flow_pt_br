import 'package:flutter/material.dart';
import 'package:spin_flow/infra/config/cores_app.dart';
import 'package:spin_flow/controller/controlador_aluno.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_aluno.dart';

class ListaAlunos extends StatefulWidget {
  const ListaAlunos({super.key});

  @override
  State<ListaAlunos> createState() => _ListaAlunosState();
}

class _ListaAlunosState extends State<ListaAlunos> {
  final _controlador = ControladorAluno();
  late Future<List<Aluno>> _alunosFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _alunosFuture = _controlador.listar();
    });
  }

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
      body: FutureBuilder<List<Aluno>>(
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
          ).push(MaterialPageRoute(builder: (_) => const FormAluno()));
          _carregar();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
