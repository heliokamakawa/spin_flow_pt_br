import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/configuracao_abas.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/controller/sessao_usuario.dart';
import 'package:spin_flow/infra/config/rotas.dart';
import 'package:spin_flow/view/gestao_administrativa/tela_gestao_administrativa.dart';
import 'package:spin_flow/view/gestao_aula/tela_operacao_aula.dart';
import 'package:spin_flow/view/gestao_aula/tela_repertorio.dart';

class TelaDashboardProfessora extends StatefulWidget {
  const TelaDashboardProfessora({super.key});

  @override
  State<TelaDashboardProfessora> createState() =>
      _TelaDashboardProfessoraState();
}

class _TelaDashboardProfessoraState extends State<TelaDashboardProfessora>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: [
          if (SessaoUsuario.alunoId != null)
            IconButton(
              icon: const Icon(Icons.directions_bike),
              tooltip: 'Entrar como aluna',
              onPressed: () =>
                  Navigator.pushNamed(context, Rotas.dashboardAluno),
            ),
          const AcaoSairAppBar(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            ConfiguracaoAbas.texto('Aulas'),
            ConfiguracaoAbas.texto('Repertorio'),
            ConfiguracaoAbas.texto('Administrativo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TelaOperacaoAula(),
          TelaRepertorio(),
          TelaGestaoAdministrativa(exibirAppBar: false),
        ],
      ),
    );
  }
}
