import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class TelaEscolhaPerfilProfessora extends StatelessWidget {
  final String nome;
  final VoidCallback onEntrarComoProfessora;
  final VoidCallback onEntrarComoAluna;

  const TelaEscolhaPerfilProfessora({
    super.key,
    required this.nome,
    required this.onEntrarComoProfessora,
    required this.onEntrarComoAluna,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Olá, $nome!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onEntrarComoProfessora,
              child: const Text('Entrar como Professora'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onEntrarComoAluna,
              child: const Text('Entrar como Aluna'),
            ),
          ],
        ),
      ),
    );
  }
}
