import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spin_flow/core/tema/cores_app.dart';

class LogoSpinFlow extends StatelessWidget {
  final double larguraIcone;
  final double alturaIcone;
  final double tamanhoFonte;
  final Color corTexto;
  final Color corDestaque;

  const LogoSpinFlow({
    super.key,
    this.larguraIcone = 38,
    this.alturaIcone = 16,
    this.tamanhoFonte = 22,
    this.corTexto = Colors.white,
    this.corDestaque = CoresApp.primaria,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SpinFlow',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(larguraIcone, alturaIcone),
            painter: _EcgPainter(cor: corDestaque),
          ),
          const SizedBox(width: 7),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'Spin', style: _estiloLogo(corTexto)),
                TextSpan(text: 'Flow', style: _estiloLogo(corDestaque)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _estiloLogo(Color cor) {
    return GoogleFonts.anton(
      fontSize: tamanhoFonte,
      color: cor,
      fontStyle: FontStyle.italic,
      letterSpacing: 0.4,
      height: 1,
    );
  }
}

class TituloAppBarSpinFlow extends StatelessWidget {
  final String? contexto;

  const TituloAppBarSpinFlow({super.key, this.contexto});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoSpinFlow(),
        if (contexto != null) ...[
          const SizedBox(height: 2),
          Text(
            contexto!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
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

    final path = Path()
      ..moveTo(0, base)
      ..lineTo(w * 0.22, base)
      ..lineTo(w * 0.27, h * 0.36)
      ..lineTo(w * 0.32, base)
      ..lineTo(w * 0.36, base)
      ..lineTo(w * 0.42, h * 0.04)
      ..lineTo(w * 0.48, h * 0.92)
      ..lineTo(w * 0.55, h * 0.22)
      ..lineTo(w * 0.62, h * 0.68)
      ..lineTo(w * 0.67, base)
      ..lineTo(w, base);

    canvas.drawPath(path, traco);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) {
    return oldDelegate.cor != cor;
  }
}
