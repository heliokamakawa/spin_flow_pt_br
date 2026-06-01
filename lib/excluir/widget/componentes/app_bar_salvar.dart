import 'package:flutter/material.dart';

import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class AppBarSalvar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final VoidCallback aoSalvar;
  final String dicaAcao;

  const AppBarSalvar({
    super.key,
    required this.titulo,
    required this.aoSalvar,
    this.dicaAcao = 'Salvar',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // A seta de voltar aparece automaticamente se houver rota anterior
      title: const TituloAppBarSpinFlow(),
      actions: [
        IconButton(
          onPressed: aoSalvar,
          icon: const Icon(Icons.add),
          tooltip: dicaAcao,
        ),
        const AcaoSairAppBar(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
