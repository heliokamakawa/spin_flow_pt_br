import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'form_bike.dart';
import 'form_fabricante.dart';
import 'form_manutencao.dart';
import 'form_tipo_manutencao.dart';
import 'form_grupo_alunos.dart';
import 'form_sala.dart';
import 'form_turma.dart';
import 'lista_bikes.dart';
import 'lista_fabricantes.dart';
import 'lista_grupos_alunos.dart';
import 'lista_manutencoes.dart';
import 'lista_salas.dart';
import 'lista_tipo_manutencao.dart';
import 'lista_turmas.dart';
import '../gestao_aula/form_aluno.dart';
import 'package:spin_flow/view/gestao_aula/lista_alunos.dart';

class TelaGestaoAdministrativa extends StatelessWidget {
  final bool exibirAppBar;

  const TelaGestaoAdministrativa({super.key, this.exibirAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: exibirAppBar
          ? AppBar(
              title: const TituloAppBarSpinFlow(),
              actions: const [AcaoSairAppBar()],
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ItemGestao(
            icone: Icons.directions_bike,
            titulo: 'Bikes',
            onCadastro: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FormBike())),
            onLista: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ListaBikes())),
          ),
          _ItemGestao(
            icone: Icons.precision_manufacturing,
            titulo: 'Fabricantes',
            onCadastro: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FormFabricante())),
            onLista: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ListaFabricantes())),
          ),
          _ItemGestao(
            icone: Icons.person,
            titulo: 'Alunos',
            onCadastro: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FormAluno())),
            onLista: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ListaAlunos())),
          ),
          _ItemGestao(
            icone: Icons.build_circle,
            titulo: 'Manutenções',
            onCadastro: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FormManutencao())),
            onLista: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ListaManutencoes())),
          ),
          _ItemGestao(
            icone: Icons.category,
            titulo: 'Tipos de Manutenção',
            onCadastro: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FormTipoManutencao()),
            ),
            onLista: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ListaTipoManutencao()),
            ),
          ),
          _ItemGestao(
            icone: Icons.meeting_room,
            titulo: 'Salas',
            onCadastro: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FormSala())),
            onLista: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ListaSalas())),
          ),
          _ItemGestao(
            icone: Icons.groups,
            titulo: 'Turmas',
            onCadastro: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FormTurma())),
            onLista: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ListaTurmas())),
          ),
          _ItemGestao(
            icone: Icons.group_work,
            titulo: 'Grupos de Alunos',
            onCadastro: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FormGrupoAlunos())),
            onLista: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ListaGruposAlunos()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemGestao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onCadastro;
  final VoidCallback onLista;

  const _ItemGestao({
    required this.icone,
    required this.titulo,
    required this.onCadastro,
    required this.onLista,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icone, size: 28),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onTap: onCadastro,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: 'Ver lista',
              onPressed: onLista,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Novo cadastro',
              onPressed: onCadastro,
            ),
          ],
        ),
      ),
    );
  }
}
