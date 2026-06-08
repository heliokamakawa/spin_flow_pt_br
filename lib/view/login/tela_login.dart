import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/infra/config/rotas.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_login.dart';
import 'package:spin_flow/view/componentes/campo_identificador_login.dart';
import 'package:spin_flow/view/componentes/campo_senha.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

// ── Linha ECG via Canvas ─────────────────────────────────────────────────────

class _IconeEcg extends StatelessWidget {
  final double largura;
  final double altura;
  final Color cor;

  const _IconeEcg({
    required this.largura,
    required this.altura,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(largura, altura),
      painter: _EcgPainter(cor: cor),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final Color cor;
  const _EcgPainter({required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = h * 0.58;

    final traco = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.034
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, base);
    path.lineTo(w * 0.22, base); // flat esquerda
    path.lineTo(w * 0.27, h * 0.36); // P wave (bump pequeno)
    path.lineTo(w * 0.32, base); // volta base
    path.lineTo(w * 0.36, base); // flat
    path.lineTo(w * 0.42, h * 0.04); // spike R (alto)
    path.lineTo(w * 0.48, h * 0.92); // dip S (profundo)
    path.lineTo(w * 0.55, h * 0.22); // T wave (médio)
    path.lineTo(w * 0.62, h * 0.68); // dip suave
    path.lineTo(w * 0.67, base); // volta base
    path.lineTo(w * 1.00, base); // flat direita

    canvas.drawPath(path, traco);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identificadorController =
      TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final ControladorLogin _controladorLogin = ControladorLogin();
  bool _carregando = false;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final resultado = await _controladorLogin.entrar(
      identificador: _identificadorController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;

    setState(() => _carregando = false);

    if (!resultado.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensagemErro ?? Erro.erroLogin),
          backgroundColor: CoresApp.erro,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (resultado.requerEscolhaPerfil) {
      Navigator.pushReplacementNamed(context, Rotas.dashboardProfessora);
      return;
    }

    // Aluno: fluxo normal
    Navigator.pushReplacementNamed(context, resultado.rotaDestino!);
  }

  @override
  void dispose() {
    _identificadorController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const laranja = CoresApp.primaria;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem de fundo
          Image.asset(
            'docs/img/fundo.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          // Overlay gradiente: claro no topo (deixa a foto respirar),
          // escuro embaixo (contraste para o card)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CoresApp.overlayTopoLogin,
                  CoresApp.overlayMeioLogin,
                  CoresApp.overlayBaseLogin,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // Conteúdo
          SafeArea(
            child: Column(
              children: [
                // Logo — empurrado para baixo, perto do card
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Halo escuro atrás do logo — separa da foto
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.55),
                                  Colors.transparent,
                                ],
                                radius: 0.85,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _IconeEcg(
                                  largura: 120,
                                  altura: 44,
                                  cor: laranja,
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Spin',
                                        style: GoogleFonts.anton(
                                          fontSize: 56,
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 1,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.95,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(2, 3),
                                            ),
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              blurRadius: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Flow',
                                        style: GoogleFonts.anton(
                                          fontSize: 56,
                                          color: laranja,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 1,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.95,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(2, 3),
                                            ),
                                            Shadow(
                                              color: laranja.withValues(
                                                alpha: 0.6,
                                              ),
                                              blurRadius: 22,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Card com glassmorphism
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                            BoxShadow(
                              color: laranja.withValues(alpha: 0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Barra de acento da marca
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    CoresApp.primaria,
                                    CoresApp.primariaForte,
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                20,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    CampoIdentificadorLogin(
                                      controle: _identificadorController,
                                    ),
                                    const SizedBox(height: 16),
                                    CampoSenha(
                                      controle: _senhaController,
                                      rotulo: 'Senha',
                                      dica: 'Informe a senha',
                                      mensagemErro: Erro.obrigatorio,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          Rotas.recuperarSenha,
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              CoresApp.primariaForte,
                                        ),
                                        child: const Text('Esqueceu a senha?'),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _carregando
                                            ? null
                                            : _fazerLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              CoresApp.primariaEscura,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: _carregando
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Text(
                                                'Entrar',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
