import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spin_flow/controller/sessao_usuario.dart';
import 'package:spin_flow/infra/config/rotas.dart';
import 'package:spin_flow/view/componentes/tema_app.dart';
import 'package:spin_flow/view/checkin/tela_dashboard_checkin.dart';
import 'package:spin_flow/view/gestao_aula/lista_alunos.dart';
import 'package:spin_flow/view/gestao_aula/tela_dashboard_professora.dart';
import 'package:spin_flow/view/login/tela_login.dart';
import 'package:spin_flow/view/login/tela_recuperar_senha.dart';
import 'package:spin_flow/view/login/tela_sessao_expirada.dart';

class SpinFlowApp extends StatelessWidget {
  const SpinFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpinFlow',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      initialRoute: Rotas.login,
      navigatorObservers: [_SessaoObserver()],
      routes: {
        Rotas.login: (context) => const TelaLogin(),
        Rotas.dashboardAluno: (context) => const TelaDashboardCheckin(),
        Rotas.dashboardProfessora: (context) => const TelaDashboardProfessora(),
        Rotas.recuperarSenha: (context) => const TelaRecuperarSenha(),
        Rotas.sessaoExpirada: (context) => const TelaSessaoExpirada(),
        Rotas.listaAlunos: (context) => const ListaAlunos(),
      },
    );
  }
}

class _SessaoObserver extends NavigatorObserver {
  static const _rotasPublicas = {
    Rotas.login,
    Rotas.recuperarSenha,
    Rotas.sessaoExpirada,
  };

  @override
  void didPush(Route route, Route? previousRoute) {
    _verificar(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _verificar(newRoute);
  }

  void _verificar(Route route) {
    final nome = route.settings.name;
    if (nome != null && _rotasPublicas.contains(nome)) return;

    if (SessaoUsuario.ativa && SessaoUsuario.expirada) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nav = navigator;
        if (nav == null) return;
        SessaoUsuario.encerrar();
        nav.pushNamedAndRemoveUntil(Rotas.sessaoExpirada, (r) => false);
      });
    } else {
      SessaoUsuario.registrarAtividade();
    }
  }
}
