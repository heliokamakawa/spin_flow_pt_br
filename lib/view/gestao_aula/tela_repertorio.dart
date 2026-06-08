import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/painel_mix_professora.dart';
import 'form_artista_banda.dart';
import 'form_mix.dart';
import 'form_musica.dart';
import 'form_videoaulas_musica.dart';
import 'lista_artistas_bandas.dart';
import 'lista_mixes.dart';
import 'lista_musicas.dart';
import 'lista_videoaulas_musica.dart';

class TelaRepertorio extends StatelessWidget {
  const TelaRepertorio({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PainelMixProfessora(),
        _ItemRepertorio(
          icone: Icons.mic,
          titulo: 'Artista ou banda',
          onCadastro: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FormArtistaBanda()),
          ),
          onLista: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ListaArtistasBandas()),
          ),
        ),
        _ItemRepertorio(
          icone: Icons.music_note,
          titulo: 'Música',
          onCadastro: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FormMusica()),
          ),
          onLista: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ListaMusicas()),
          ),
        ),
        _ItemRepertorio(
          icone: Icons.play_circle_outline,
          titulo: 'Videoaula da música',
          onCadastro: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FormVideoaulaMusica()),
          ),
          onLista: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ListaVideoaulasMusica()),
          ),
        ),
        _ItemRepertorio(
          icone: Icons.queue_music,
          titulo: 'Mix',
          onCadastro: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FormMix()),
          ),
          onLista: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ListaMixes()),
          ),
        ),
      ],
    );
  }
}

class _ItemRepertorio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onCadastro;
  final VoidCallback onLista;

  const _ItemRepertorio({
    required this.icone,
    required this.titulo,
    required this.onCadastro,
    required this.onLista,
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
        onTap: onCadastro,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: 'Ver lista',
              onPressed: onLista,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Novo cadastro',
              onPressed: onCadastro,
            ),
          ],
        ),
      ),
    );
  }
}
