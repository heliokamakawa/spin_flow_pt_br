import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_mix.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_repertorio_professora.dart';
import 'package:spin_flow/domain/modelo/musica_repertorio_professora.dart';
import 'package:spin_flow/infra/config/cores_app.dart';
import 'package:spin_flow/infra/config/tema_app.dart';

/// Abre o painel de avaliações do mix no dashboard da professora.
class PainelMixProfessora extends StatelessWidget {
  const PainelMixProfessora({super.key});

  static void abrirModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ModalMixProfessora(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.bar_chart, size: 28),
        title: const Text(
          'Avaliações do Repertório',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Médias das músicas avaliadas pelos alunos'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => abrirModal(context),
      ),
    );
  }
}

// -- Modal -------------------------------------------------------------------

class _ModalMixProfessora extends StatefulWidget {
  const _ModalMixProfessora();

  @override
  State<_ModalMixProfessora> createState() => _ModalMixProfessoraState();
}

class _ModalMixProfessoraState extends State<_ModalMixProfessora> {
  final _controlador = ControladorMix();

  List<Mix> _mixes = [];
  Mix? _mixSelecionado;
  MixRepertorioProfessora? _repertorio;
  bool _carregandoLista = true;
  bool _carregandoMix = false;

  @override
  void initState() {
    super.initState();
    _carregarMixes();
  }

  Future<void> _carregarMixes() async {
    final lista = await _controlador.listar();
    if (!mounted) return;
    setState(() {
      _mixes = lista;
      _carregandoLista = false;
    });
  }

  Future<void> _selecionarMix(Mix mix) async {
    setState(() {
      _mixSelecionado = mix;
      _carregandoMix = true;
      _repertorio = null;
    });
    final resultado = await _controlador.buscarComMedias(mix.id!);
    if (!mounted) return;
    setState(() {
      _repertorio = resultado;
      _carregandoMix = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final alturaMax = MediaQuery.of(context).size.height * 0.85;

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
          // Título
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.bar_chart, size: 18),
                SizedBox(width: 8),
                Text(
                  'Avaliações do Repertório',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          // Seletor de mix
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _carregandoLista
                ? const LinearProgressIndicator()
                : DropdownButton<Mix>(
                    value: _mixSelecionado,
                    hint: const Text('Selecione um mix'),
                    isExpanded: true,
                    items: _mixes.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m.nome, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (m) { if (m != null) _selecionarMix(m); },
                  ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Conteúdo
          Flexible(child: _buildConteudo()),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_mixSelecionado == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Selecione um mix para ver as avaliações.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CoresApp.textoFraco),
          ),
        ),
      );
    }
    if (_carregandoMix) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ));
    }
    if (_repertorio == null || _repertorio!.musicas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Nenhuma música encontrada para este mix.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CoresApp.textoFraco),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _repertorio!.musicas.length,
      itemBuilder: (_, i) => _LinhaMusica(musica: _repertorio!.musicas[i]),
    );
  }
}

// -- Linha de música ---------------------------------------------------------

class _LinhaMusica extends StatelessWidget {
  final MusicaRepertorioProfessora musica;

  const _LinhaMusica({required this.musica});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final media = musica.mediaAvaliacao;
    final estrelasPreenchidas = media != null ? media.round() : 0;

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        musica.nome,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (musica.totalAvaliadores > 0)
                      Text(
                        '(${musica.totalAvaliadores})',
                        style: TextStyle(fontSize: 11, color: cores.textoFraco),
                      ),
                  ],
                ),
                if (musica.nomeArtista.isNotEmpty)
                  Text(
                    musica.nomeArtista,
                    style: TextStyle(fontSize: 12, color: cores.textoFraco),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final preenchida = i < estrelasPreenchidas;
              return Icon(
                preenchida ? Icons.star : Icons.star_border,
                size: 18,
                color: media == null
                    ? cores.textoFraco.withValues(alpha: 0.4)
                    : preenchida
                        ? Colors.amber
                        : cores.textoFraco,
              );
            }),
          ),
        ],
      ),
    );
  }
}
