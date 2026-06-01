import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spin_flow/excluir/spim_flow_app.dart';

/// Teste de integraÃ§Ã£o â€” Fluxo do Aluno
/// Faz login como aluno e navega por todas as telas do sistema.
///
/// Comando: flutter test integration_test/test_fluxo_aluno.dart -d <DEVICE_ID>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo Aluno - Apresentacao Geral', () {
    testWidgets('Login e navegacao por todas as telas', (tester) async {
      await tester.pumpWidget(const SpinFlowApp());

      // â”€â”€ Splash â”€â”€
      // Aguarda splash animar e ir para login
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // â”€â”€ Login â”€â”€
      expect(find.text('SpinFlow'), findsWidgets);
      expect(find.text('Entrar'), findsOneWidget);

      // Preencher email
      final campoEmail = find.byType(TextFormField).first;
      await tester.tap(campoEmail);
      await tester.pumpAndSettle();
      await tester.enterText(campoEmail, 'aluno@gmail.com');
      await tester.pumpAndSettle();

      // Preencher senha
      final campoSenha = find.byType(TextFormField).at(1);
      await tester.tap(campoSenha);
      await tester.pumpAndSettle();
      await tester.enterText(campoSenha, '123');
      await tester.pumpAndSettle();

      // Tap no botÃ£o Entrar
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // â”€â”€ Dashboard Aluno (Meu Painel) â”€â”€
      expect(find.text('Meu Painel'), findsWidgets);
      expect(find.text('Resumo geral'), findsOneWidget);
      expect(find.text('Indicadores'), findsOneWidget);
      expect(find.text('Acessos rapidos'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Abrir Drawer â”€â”€
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      await _pausaApresentacao(tester);

      // â”€â”€ Navegar para: Check-in (via Drawer) â”€â”€
      await tester.tap(find.text('Check-in'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Check-in de Hoje'), findsOneWidget);
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Historico (via Drawer) â”€â”€
      // Reabrir drawer
      final scaffoldState2 = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState2.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Historico'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Meu Historico'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Historico: Aba "Todas" (padrÃ£o) â”€â”€
      expect(find.text('Todas'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Historico: Aba "Este mes" â”€â”€
      await tester.tap(find.text('Este mes'));
      await tester.pumpAndSettle();
      await _pausaApresentacao(tester);

      // â”€â”€ Historico: Aba "Ultimos 3 meses" â”€â”€
      await tester.tap(find.text('Ultimos 3 meses'));
      await tester.pumpAndSettle();
      await _pausaApresentacao(tester);

      // â”€â”€ Voltar para aba Todas â”€â”€
      await tester.tap(find.text('Todas'));
      await tester.pumpAndSettle();

      // â”€â”€ Tentar abrir detalhe de aula (se houver check-ins) â”€â”€
      final cards = find.byType(InkWell);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        // Verifica se abriu a tela de detalhe
        final detalheAberto = find.text('Detalhe da Aula').evaluate().isNotEmpty;
        if (detalheAberto) {
          await _pausaApresentacao(tester);
          await _voltar(tester);
        }
      }

      await _voltar(tester); // Volta do Historico

      // â”€â”€ Navegar para: Indicadores Detalhados (via Acessos rapidos) â”€â”€
      // Scroll down para encontrar os acessos rapidos
      await tester.scrollUntilVisible(
        find.text('Indicadores'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Encontra o tile de Indicadores nos acessos rapidos
      final indicadoresTile = find.widgetWithText(Card, 'Indicadores');
      if (indicadoresTile.evaluate().isNotEmpty) {
        await tester.tap(indicadoresTile.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.text('Indicadores Detalhados'), findsOneWidget);
        await _pausaApresentacao(tester);
        await _voltar(tester);
      }

      // â”€â”€ Navegar para: Historico de aulas (via Acessos rapidos) â”€â”€
      await tester.scrollUntilVisible(
        find.text('Historico de aulas'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final historicoTile = find.widgetWithText(Card, 'Historico de aulas');
      if (historicoTile.evaluate().isNotEmpty) {
        await tester.tap(historicoTile.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.text('Meu Historico'), findsOneWidget);
        await _pausaApresentacao(tester);
        await _voltar(tester);
      }

      // â”€â”€ Navegar para: Agenda completa (via Acessos rapidos) â”€â”€
      await tester.scrollUntilVisible(
        find.text('Agenda completa'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final agendaTile = find.widgetWithText(Card, 'Agenda completa');
      if (agendaTile.evaluate().isNotEmpty) {
        await tester.tap(agendaTile.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.text('Agenda Semanal'), findsOneWidget);
        await _pausaApresentacao(tester);
        await _voltar(tester);
      }

      // â”€â”€ Navegar para: Mix da turma (via Acessos rapidos) â”€â”€
      await tester.scrollUntilVisible(
        find.text('Mix da turma'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final mixTile = find.widgetWithText(Card, 'Mix da turma');
      if (mixTile.evaluate().isNotEmpty) {
        await tester.tap(mixTile.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await _pausaApresentacao(tester);
        await _voltar(tester);
      }

      // â”€â”€ Navegar para: Check-in (via card destaque) â”€â”€
      await tester.scrollUntilVisible(
        find.text('Fazer check-in agora'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fazer check-in agora'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Check-in de Hoje'), findsOneWidget);
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Perfil (via Drawer) â”€â”€
      final scaffoldState3 = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState3.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Voltar para Dashboard e verificar estado final â”€â”€
      expect(find.text('Meu Painel'), findsWidgets);
      await _pausaApresentacao(tester);

      // â”€â”€ Testar Logout e tela de Recuperar Senha â”€â”€
      final scaffoldState4 = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState4.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Deve estar na tela de login
      expect(find.text('SpinFlow'), findsWidgets);
      expect(find.text('Entrar'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Navegar para: Recuperar Senha â”€â”€
      final esqueceuSenha = find.text('Esqueceu a senha?');
      if (esqueceuSenha.evaluate().isNotEmpty) {
        await tester.tap(esqueceuSenha);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await _pausaApresentacao(tester);
        await _voltar(tester);
      }

      // âœ… Teste concluÃ­do com sucesso!
    });
  });
}

/// Pausa de 2 segundos para visualizar a tela na apresentaÃ§Ã£o.
Future<void> _pausaApresentacao(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
}

/// Simula o botÃ£o voltar do AppBar.
Future<void> _voltar(WidgetTester tester) async {
  final backButton = find.byType(BackButton);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  } else {
    // Fallback: tenta o Ã­cone de voltar
    final arrowBack = find.byIcon(Icons.arrow_back);
    if (arrowBack.evaluate().isNotEmpty) {
      await tester.tap(arrowBack.first);
      await tester.pumpAndSettle();
    }
  }
}
