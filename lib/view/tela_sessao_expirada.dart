import 'package:flutter/material.dart';
import 'package:spin_flow/controller/sessao_usuario.dart';
import 'package:spin_flow/infra/config/rotas.dart';
import 'package:spin_flow/infra/config/cores_app.dart';

class TelaSessaoExpirada extends StatelessWidget {
  const TelaSessaoExpirada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock, size: 72, color: CoresApp.alerta),
              const SizedBox(height: 20),
              const Text(
                'Sessão expirada',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sua sessão expirou por inatividade. Por favor, faça login novamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SessaoUsuario.encerrar();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Rotas.login,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Ir para o login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
