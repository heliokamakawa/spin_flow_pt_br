import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_musica.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/domain/modelo/video_aula.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_videoaulas_musica.dart';

class _MusicaComVideos {
  final Musica musica;
  final List<VideoAula> videos;
  const _MusicaComVideos({required this.musica, required this.videos});
}

class ListaVideoaulasMusica extends StatefulWidget {
  const ListaVideoaulasMusica({super.key});

  @override
  State<ListaVideoaulasMusica> createState() => _ListaVideoaulasMusicaState();
}

class _ListaVideoaulasMusicaState extends State<ListaVideoaulasMusica> {
  final _controlador = ControladorMusica();
  final _buscaController = TextEditingController();
  List<_MusicaComVideos> _dados = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() => setState(() {}));
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final musicas = await _controlador.listar();
    final lista = <_MusicaComVideos>[];
    for (final m in musicas) {
      final videos = m.id != null
          ? await _controlador.buscarVideos(m.id!)
          : <VideoAula>[];
      lista.add(_MusicaComVideos(musica: m, videos: videos));
    }
    if (!mounted) return;
    setState(() {
      _dados = lista;
      _carregando = false;
    });
  }

  List<_MusicaComVideos> _filtrar() => filtrarComPrioridade(
    _dados,
    _buscaController.text,
    (d) => [d.musica.nome, d.musica.nomeArtista],
  );

  Future<void> _adicionarVideo([Musica? musica]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormVideoaulaMusica(musica: musica)),
    );
    if (atualizado == true) _carregar();
  }

  Future<void> _removerVideo(Musica musica, VideoAula video) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover videoaula'),
        content: Text('Remover "${video.linkVideo}" de "${musica.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: CoresApp.erro)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final resultado = await _controlador.removerVideoAula(musica.id!, video.id!);
    if (!mounted) return;
    if (!resultado.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensagemErro!),
          backgroundColor: CoresApp.erro,
        ),
      );
      return;
    }
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarVideo(),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                CampoBusca(controlador: _buscaController, dica: 'Buscar música ou artista...'),
                Expanded(
                  child: _dados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhuma música cadastrada',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : Builder(
                          builder: (_) {
                            final itens = _filtrar();
                            if (itens.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhum resultado para "${_buscaController.text}"',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: itens.length,
                              itemBuilder: (_, i) {
                                final item = itens[i];
                                return _CardMusicaComVideos(
                                  item: item,
                                  onAdicionar: () => _adicionarVideo(item.musica),
                                  onRemover: (v) => _removerVideo(item.musica, v),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _CardMusicaComVideos extends StatelessWidget {
  final _MusicaComVideos item;
  final VoidCallback onAdicionar;
  final void Function(VideoAula) onRemover;

  const _CardMusicaComVideos({
    required this.item,
    required this.onAdicionar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final musica = item.musica;
    final videos = item.videos;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: videos.isNotEmpty ? CoresApp.info : CoresApp.textoFraco,
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
            title: Text(musica.nome),
            subtitle: Text(
              musica.nomeArtista.isNotEmpty
                  ? '${musica.nomeArtista} · ${videos.length} videoaula(s)'
                  : '${videos.length} videoaula(s)',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: CoresApp.sucesso),
              tooltip: 'Adicionar videoaula',
              onPressed: onAdicionar,
            ),
          ),
          if (videos.isNotEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...videos.map(
              (v) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.play_circle_outline,
                  size: 20,
                  color: CoresApp.info,
                ),
                title: Text(
                  v.linkVideo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: CoresApp.erro),
                  tooltip: 'Remover',
                  onPressed: () => onRemover(v),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
