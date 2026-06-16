import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_musica.dart';
import 'package:spin_flow/domain/modelo/artista_banda.dart';
import 'package:spin_flow/domain/modelo/categoria_musica.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/campo_busca_multipla.dart';
import 'form_artista_banda.dart';

class FormMusica extends StatefulWidget {
  final Musica? musica;
  const FormMusica({super.key, this.musica});

  @override
  State<FormMusica> createState() => _FormMusicaState();
}

class _FormMusicaState extends State<FormMusica> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ControladorMusica();

  final _nomeCtrl = TextEditingController();
  List<ArtistaBanda> _artistas = [];
  List<CategoriaMusica> _categoriasDisponiveis = [];
  List<CategoriaMusica> _categoriasSelecionadas = [];
  int? _artistaId;
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final m = widget.musica;
    if (m != null) {
      _nomeCtrl.text = m.nome;
      _artistaId = m.artistaId;
    }
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final artistas = await _controlador.listarArtistas();
    final categorias = await _controlador.listarCategorias();
    final categoriasSelecionadas = widget.musica?.id != null
        ? await _controlador.buscarCategorias(widget.musica!.id!)
        : <CategoriaMusica>[];

    if (!mounted) return;
    setState(() {
      _artistas = artistas;
      _categoriasDisponiveis = categorias;
      _categoriasSelecionadas = categoriasSelecionadas;
      _carregando = false;
    });
  }

  Future<void> _novoArtista() async {
    final criado = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const FormArtistaBanda()));
    if (criado == true) {
      final artistas = await _controlador.listarArtistas();
      if (!mounted) return;
      setState(() => _artistas = artistas);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final musica = Musica(
      id: widget.musica?.id,
      nome: _nomeCtrl.text.trim(),
      artistaId: _artistaId,
    );

    final nomes = _categoriasSelecionadas.map((c) => c.nome).toList();
    final resultado = await _controlador.salvarComCategorias(musica, nomes);
    if (!mounted) return;
    setState(() => _salvando = false);

    if (!resultado.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensagemErro!),
          backgroundColor: CoresApp.erro,
        ),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome *',
                      hintText: 'Nome da música',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _artistaId,
                          hint: const Text('Selecione'),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Artista ou banda *',
                          ),
                          items: _artistas.map((a) {
                            return DropdownMenuItem(
                              value: a.id,
                              child: Text(a.nome),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _artistaId = v),
                          validator: (v) =>
                              v == null ? 'Selecione um artista.' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _novoArtista,
                        icon: const Icon(Icons.add),
                        label: const Text('Novo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Categorias',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CampoBuscaMultipla<CategoriaMusica>(
                    opcoes: _categoriasDisponiveis,
                    selecionados: _categoriasSelecionadas,
                    getNome: (c) => c.nome,
                    saoIguais: (a, b) {
                      if (a.id != null && b.id != null) return a.id == b.id;
                      return a.nome.toLowerCase() == b.nome.toLowerCase();
                    },
                    aoAlterar: (lista) =>
                        setState(() => _categoriasSelecionadas = lista),
                    hintBusca: 'Buscar ou criar categoria...',
                    criarNovo: (texto) => CategoriaMusica(nome: texto),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tema.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _salvando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
