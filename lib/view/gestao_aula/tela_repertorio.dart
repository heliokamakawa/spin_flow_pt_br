import 'package:flutter/material.dart';
import 'form_artista_banda.dart';
import 'form_mix.dart';
import 'form_musica.dart';
import 'form_videoaulas_musica.dart';

class TelaRepertorio extends StatelessWidget {
  const TelaRepertorio({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ItemRepertorio(
          icone: Icons.mic,
          titulo: 'Artista ou banda',
          subtitulo: 'Cadastro base dos responsáveis pelas músicas',
          aoTocar: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormArtistaBanda())),
        ),
        _ItemRepertorio(
          icone: Icons.music_note,
          titulo: 'Música',
          subtitulo: 'Música com artista e categorias',
          aoTocar: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormMusica())),
        ),
        _ItemRepertorio(
          icone: Icons.play_circle_outline,
          titulo: 'Videoaula da música',
          subtitulo: 'Associa um link de videoaula a uma música',
          aoTocar: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FormVideoaulaMusica()),
          ),
        ),
        _ItemRepertorio(
          icone: Icons.queue_music,
          titulo: 'Mix',
          subtitulo: 'Sequência de músicas da aula',
          aoTocar: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormMix())),
        ),
      ],
    );
  }
}

class _ItemRepertorio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback aoTocar;

  const _ItemRepertorio({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icone, size: 28),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: aoTocar,
      ),
    );
  }
}
