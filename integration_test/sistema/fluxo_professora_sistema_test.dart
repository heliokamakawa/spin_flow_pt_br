import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spin_flow/excluir/spim_flow_app.dart';

/// Teste de integraÃ§Ã£o â€” Fluxo da Professora
/// Faz login como professora e navega por todas as telas do sistema.
///
/// Comando: flutter test integration_test/test_fluxo_professora.dart -d <DEVICE_ID>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo Professora - Apresentacao Geral', () {
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
      await tester.enterText(campoEmail, 'professora@gmail.com');
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

      // â”€â”€ Dashboard Professora â”€â”€
      expect(find.text('Dashboard da Professora'), findsOneWidget);

      // Aba 1: VisÃ£o Geral (jÃ¡ Ã© a aba padrÃ£o)
      expect(find.text('Alunos Ativos'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Aba 2: Cadastros â”€â”€
      await tester.tap(find.text('Cadastros'));
      await tester.pumpAndSettle();
      expect(find.text('Cadastros Simples'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Aba 3: Listas â”€â”€
      await tester.tap(find.text('Listas'));
      await tester.pumpAndSettle();
      expect(find.text('Listas Simples'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Aba 4: Aulas â”€â”€
      await tester.tap(find.text('Aulas'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar Check-in'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Aba 5: ManutenÃ§Ã£o â”€â”€
      await tester.tap(find.text('ManutenÃ§Ã£o'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar ManutenÃ§Ã£o'), findsOneWidget);
      await _pausaApresentacao(tester);

      // â”€â”€ Navegar para: Lista de Alunos â”€â”€
      await tester.tap(find.text('Listas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alunos'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Lista de Turmas â”€â”€
      await tester.tap(find.text('Turmas').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Lista de Bikes â”€â”€
      await tester.tap(find.text('Bikes').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Lista de Mixes â”€â”€
      await tester.tap(find.text('Mixes'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Lista de ManutenÃ§Ãµes â”€â”€
      await tester.tap(find.text('ManutenÃ§Ãµes'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Lista de Check-ins â”€â”€
      await tester.tap(find.text('Check-ins'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Aba Aulas â†’ Mapa Operacional â”€â”€
      await tester.tap(find.text('Aulas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mapa operacional (cancelar check-ins)'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Mapa Operacional (Professora)'), findsOneWidget);
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Posicionamento de Bikes â”€â”€
      await tester.tap(find.text('Posicionamento de Bikes'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: RelatÃ³rios Gerenciais â”€â”€
      await tester.tap(find.text('RelatÃ³rios Gerenciais'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: Aba Cadastros â†’ FormulÃ¡rio de Aluno â”€â”€
      await tester.tap(find.text('Cadastros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alunos'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: FormulÃ¡rio de Turma â”€â”€
      await tester.tap(find.text('Turmas'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: FormulÃ¡rio de Sala â”€â”€
      await tester.tap(find.text('Sala'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: FormulÃ¡rio de Bike â”€â”€
      await tester.tap(find.text('Cadastros com AssociaÃ§Ãµes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bikes'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Navegar para: FormulÃ¡rio de Mix â”€â”€
      await tester.tap(find.text('Mix'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _pausaApresentacao(tester);
      await _voltar(tester);

      // â”€â”€ Voltar para VisÃ£o Geral â”€â”€
      await tester.tap(find.text('VisÃ£o Geral'));
      await tester.pumpAndSettle();
      expect(find.text('Alunos Ativos'), findsOneWidget);
      await _pausaApresentacao(tester);

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
