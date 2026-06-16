// ─────────────────────────────────────────────────────────────────────────────
// Teste de integração que também serve de APRESENTAÇÃO do app SpinFlow.
//
// Faz login como aluna e como professora (senha 123) e percorre as principais
// funcionalidades de cada perfil — abas, listas e formulários — com uma pausa
// entre cada ação para dar tempo de acompanhar na tela do emulador.
//
// Como executar (com um emulador/dispositivo aberto):
//   flutter test integration_test/demo_apresentacao_test.dart
// ou, para rodar via driver:
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/demo_apresentacao_test.dart
//
// Contas usadas (do seed): aluna@gmail.com e professora@gmail.com — senha 123.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:spin_flow/infra/config/injecao.dart';
import 'package:spin_flow/infra/database/sqlite/dao/dao_usuario_sqlite.dart';
import 'package:spin_flow/view/spin_flow_app.dart';

/// Pausa entre cada ação para dar tempo de visualizar (apresentação).
const Duration _pausa = Duration(milliseconds: 1500);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Registra as dependências (DAOs). Ignora se já estiverem registradas.
    try {
      configurarDependencias();
    } catch (_) {}

    // Garante a senha 123 para as contas de demonstração (defensivo — o seed já
    // usa 123, mas o banco pode ter sido alterado em execuções anteriores).
    try {
      final dao = DAOUsuarioSQLite();
      for (final email in ['aluna@gmail.com', 'professora@gmail.com']) {
        final usuario = await dao.buscarPorEmail(email);
        if (usuario != null) await dao.atualizarSenha(usuario.id, '123');
      }
    } catch (_) {}
  });

  testWidgets('Demonstração SpinFlow — aluno e professora', (tester) async {
    await tester.pumpWidget(const SpinFlowApp());
    await _assentar(tester);

    // ───────────────────────── PERFIL ALUNO ─────────────────────────────────
    await _login(tester, 'aluna@gmail.com', '123');
    expect(find.widgetWithText(Tab, 'Meu Painel'), findsOneWidget,
        reason: 'login da aluna deveria abrir o dashboard do aluno');
    await _tourAluno(tester);
    await _logout(tester);

    // ─────────────────────── PERFIL PROFESSORA ───────────────────────────────
    await _login(tester, 'professora@gmail.com', '123');
    expect(find.text('Repertorio'), findsWidgets,
        reason: 'login da professora deveria abrir o dashboard da professora');
    await _tourProfessora(tester);
    await _logout(tester);
  });
}

// ── Helpers de ritmo ─────────────────────────────────────────────────────────

/// Renderiza tudo o que estiver pendente e aguarda a pausa de apresentação.
Future<void> _assentar(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await Future.delayed(_pausa);
  await tester.pumpAndSettle();
}

/// Toca em um elemento (se existir), rolando até ele quando possível.
/// Nunca lança — em uma demo, um passo que falha apenas é ignorado.
Future<void> _toque(WidgetTester tester, Finder alvo) async {
  try {
    if (alvo.evaluate().isEmpty) return;
    final um = alvo.first;
    try {
      await tester.ensureVisible(um);
      await tester.pumpAndSettle();
    } catch (_) {}
    await tester.tap(um, warnIfMissed: false);
    await _assentar(tester);
  } catch (e) {
    debugPrint('demo: toque ignorado ($e)');
  }
}

/// Volta uma tela.
///
/// Não usa `tester.pageBack()` porque ele procura o tooltip "Back" (em inglês),
/// mas o app está localizado em pt-BR (tooltip "Voltar"). Toca no [BackButton]
/// padrão da AppBar e, se não houver, faz `pop` programático no Navigator.
Future<void> _voltar(WidgetTester tester) async {
  try {
    final botaoVoltar = find.byType(BackButton);
    if (botaoVoltar.evaluate().isNotEmpty) {
      await tester.tap(botaoVoltar.first, warnIfMissed: false);
      await _assentar(tester);
      return;
    }
    final navegador = tester.state<NavigatorState>(find.byType(Navigator).first);
    if (navegador.canPop()) {
      navegador.pop();
      await _assentar(tester);
    }
  } catch (e) {
    debugPrint('demo: voltar ignorado ($e)');
  }
}

/// Rola a tela visível a partir do centro (independe de qual Scrollable é).
Future<void> _rolarTela(WidgetTester tester, double dy) async {
  try {
    final centro = tester.getCenter(find.byType(Scaffold).first);
    await tester.dragFrom(centro, Offset(0, dy));
    await _assentar(tester);
  } catch (e) {
    debugPrint('demo: rolar ignorado ($e)');
  }
}

/// Rola até um alvo ficar disponível na árvore (para listas longas).
Future<void> _rolarAte(WidgetTester tester, Finder alvo) async {
  for (var i = 0; i < 10; i++) {
    if (alvo.evaluate().isNotEmpty) {
      try {
        await tester.ensureVisible(alvo.first);
        await tester.pumpAndSettle();
      } catch (_) {}
      return;
    }
    await _rolarTela(tester, -260);
  }
}

// ── Login / Logout ───────────────────────────────────────────────────────────

Future<void> _login(WidgetTester tester, String identificador, String senha) async {
  final campos = find.byType(TextFormField);
  if (campos.evaluate().length >= 2) {
    await tester.enterText(campos.at(0), identificador);
    await _assentar(tester);
    await tester.enterText(campos.at(1), senha);
    await _assentar(tester);
  }
  await _toque(tester, find.widgetWithText(ElevatedButton, 'Entrar'));
  await _assentar(tester);
}

Future<void> _logout(WidgetTester tester) async {
  await _toque(tester, find.byIcon(Icons.account_circle_outlined));
  await _toque(tester, find.text('Sair'));
  await _assentar(tester);
}

// ── Tour do aluno ────────────────────────────────────────────────────────────

Future<void> _tourAluno(WidgetTester tester) async {
  // Aba Meu Painel: nível, indicadores e avaliação de mix.
  await _toque(tester, find.widgetWithText(Tab, 'Meu Painel'));
  await _rolarTela(tester, -280);
  await _toque(tester, find.text('Preferidas'));
  await _toque(tester, find.text('Avaliação'));
  await _toque(tester, find.text('Top 5'));
  await _rolarTela(tester, 280);

  // Aba Check-in: lista de aulas do dia.
  await _toque(tester, find.widgetWithText(Tab, 'Check-in'));

  // Abre o mapa de bikes se houver uma aula com check-in disponível.
  final botaoCheckin = find.widgetWithText(ElevatedButton, 'Check-in');
  if (botaoCheckin.evaluate().isNotEmpty) {
    await _toque(tester, botaoCheckin);
    await _voltar(tester);
  }
}

// ── Tour da professora ───────────────────────────────────────────────────────

Future<void> _tourProfessora(WidgetTester tester) async {
  // Aba Aulas (padrão).
  await _toque(tester, find.widgetWithText(OutlinedButton, 'Painel de Frequência'));
  await _voltar(tester);

  final primeiraTurma = find.byIcon(Icons.fitness_center);
  if (primeiraTurma.evaluate().isNotEmpty) {
    await _toque(tester, primeiraTurma);
    await _voltar(tester);
  }

  // Aba Repertorio — abre a lista e o formulário de cada item.
  await _toque(tester, find.text('Repertorio'));
  for (final titulo in const [
    'Artista ou banda',
    'Música',
    'Videoaula da música',
    'Mix',
  ]) {
    await _abrirListaEFormulario(tester, titulo);
  }

  // Aba Administrativo — abre a lista e o formulário de cada item.
  await _toque(tester, find.text('Administrativo'));
  for (final titulo in const [
    'Bikes',
    'Fabricantes',
    'Alunos',
    'Manutenções',
    'Tipos de Manutenção',
    'Salas',
    'Turmas',
    'Grupos de Alunos',
  ]) {
    await _abrirListaEFormulario(tester, titulo);
  }

  // Atalho "Entrar como aluna" (a professora também tem perfil de aluna).
  final comoAluna = find.byIcon(Icons.directions_bike);
  if (comoAluna.evaluate().isNotEmpty) {
    await _toque(tester, comoAluna);
    await _voltar(tester);
  }
}

/// Para um item de menu (card com título), abre a Lista e depois o Formulário,
/// voltando após cada um. Não salva nada — apenas demonstra as telas.
Future<void> _abrirListaEFormulario(WidgetTester tester, String titulo) async {
  // Abre a LISTA (ícone list_alt dentro do card do título).
  await _rolarAte(tester, find.text(titulo));
  final card = find.ancestor(
    of: find.text(titulo),
    matching: find.byType(Card),
  );
  final botaoLista = find.descendant(
    of: card,
    matching: find.byIcon(Icons.list_alt),
  );
  await _toque(tester, botaoLista);
  await _voltar(tester);

  // Abre o FORMULÁRIO (toque no título do card).
  await _rolarAte(tester, find.text(titulo));
  await _toque(tester, find.text(titulo));
  await _voltar(tester);
}
