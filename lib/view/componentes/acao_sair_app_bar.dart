import 'package:flutter/material.dart';
import 'package:spin_flow/infra/navegacao/rotas.dart';
import 'package:spin_flow/infra/autenticacao/sessao_usuario.dart';
import 'package:spin_flow/infra/tema/cores_app.dart';

class AcaoSairAppBar extends StatelessWidget {
  const AcaoSairAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final nome = SessaoUsuario.nome ?? 'Usuario';
    final primeiroNome = nome.trim().split(RegExp(r'\s+')).first;

    return PopupMenuButton<_AcaoUsuario>(
      tooltip: 'Opcoes do usuario',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      onSelected: (acao) {
        switch (acao) {
          case _AcaoUsuario.sair:
            SessaoUsuario.encerrar();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(Rotas.login, (route) => false);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_AcaoUsuario>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: CoresApp.textoPrincipal,
                ),
              ),
              if ((SessaoUsuario.perfil ?? '').isNotEmpty)
                Text(
                  SessaoUsuario.perfil!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CoresApp.textoSuave,
                  ),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<_AcaoUsuario>(
          value: _AcaoUsuario.sair,
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 10),
              Text('Sair'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle_outlined, size: 20),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 86),
              child: Text(
                primeiroNome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

enum _AcaoUsuario { sair }
