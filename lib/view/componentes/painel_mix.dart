import 'package:flutter/material.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/musica_checkin.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/tema_app.dart';

/// Botão que abre o mix da aula em um modal sobre a tela.
class PainelMix extends StatelessWidget {
  final MixCheckin mix;
  final Future<void> Function(int musicaId, int nota) onAvaliar;

  const PainelMix({required this.mix, required this.onAvaliar, super.key});

  static void abrirModal(
    BuildContext context,
    MixCheckin mix,
    Future<void> Function(int musicaId, int nota) onAvaliar,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ModalMix(mix: mix, onAvaliar: onAvaliar),
    );
  }

  void _abrirModal(BuildContext context) =>
      PainelMix.abrirModal(context, mix, onAvaliar);

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Column(
      children: [
        const Divider(height: 1),
        InkWell(
          onTap: () => _abrirModal(context),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.music_note, size: 16, color: cores.textoSuave),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    mix.nomeMix,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cores.textoSuave,
                    ),
                  ),
                ),
                Icon(Icons.open_in_new, size: 16, color: cores.textoFraco),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -- Modal -------------------------------------------------------------------

class _ModalMix extends StatefulWidget {
  final MixCheckin mix;
  final Future<void> Function(int musicaId, int nota) onAvaliar;

  const _ModalMix({required this.mix, required this.onAvaliar});

  @override
  State<_ModalMix> createState() => _ModalMixState();
}

class _ModalMixState extends State<_ModalMix> {
  late final Map<int, int> _avaliacoes;

  @override
  void initState() {
    super.initState();
    _avaliacoes = {
      for (final m in widget.mix.musicas)
        if (m.avaliacao != null) m.musicaId: m.avaliacao!,
    };
  }

  Future<void> _avaliar(int musicaId, int nota) async {
    await widget.onAvaliar(musicaId, nota);
    if (!mounted) return;
    setState(() => _avaliacoes[musicaId] = nota);
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final alturaMax = MediaQuery.of(context).size.height * 0.82;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: alturaMax),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CoresApp.borda,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Título do mix
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Icon(Icons.music_note, size: 18, color: cores.textoSuave),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.mix.nomeMix,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Lista de músicas (scrollável)
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: widget.mix.musicas.length,
              itemBuilder: (_, i) {
                final m = widget.mix.musicas[i];
                return _LinhaMusica(
                  musica: m,
                  nota: _avaliacoes[m.musicaId],
                  onAvaliar: (nota) => _avaliar(m.musicaId, nota),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -- Linha de música ---------------------------------------------------------

class _LinhaMusica extends StatelessWidget {
  final MusicaCheckin musica;
  final int? nota;
  final void Function(int nota) onAvaliar;

  const _LinhaMusica({
    required this.musica,
    required this.nota,
    required this.onAvaliar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${musica.posicao}.',
              style: TextStyle(
                fontSize: 12,
                color: cores.textoFraco,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  musica.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (musica.nomeArtista.isNotEmpty)
                  Text(
                    musica.nomeArtista,
                    style: TextStyle(fontSize: 12, color: cores.textoFraco),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final estrela = i + 1;
              return GestureDetector(
                onTap: () => onAvaliar(estrela),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    estrela <= (nota ?? 0) ? Icons.star : Icons.star_border,
                    size: 22,
                    color: estrela <= (nota ?? 0)
                        ? Colors.amber
                        : cores.textoFraco,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
