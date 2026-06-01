import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_categoria_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormCategoriasMusicaFlow extends StatefulWidget {
  const FormCategoriasMusicaFlow({super.key});

  @override
  State<FormCategoriasMusicaFlow> createState() =>
      _FormCategoriasMusicaFlowState();
}

class _FormCategoriasMusicaFlowState extends State<FormCategoriasMusicaFlow> {
  final _controlador = GetIt.I<ControladorMusica>();

  List<ModeloMusica> _musicas = [];
  ModeloMusica? _musicaSelecionada;
  List<ModeloCategoriaMusica> _categorias = [];

  final _categoriaCtrl = TextEditingController();
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarMusicas();
  }

  @override
  void dispose() {
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarMusicas() async {
    final lista = await _controlador.listar();
    if (!mounted) return;
    setState(() {
      _musicas = lista;
      _carregando = false;
    });
  }

  Future<void> _selecionarMusica(ModeloMusica musica) async {
    final cats = await _controlador.buscarCategorias(musica.id!);
    if (!mounted) return;
    setState(() {
      _musicaSelecionada = musica;
      _categorias = cats;
    });
  }

  void _adicionarCategoria() {
    final nome = _categoriaCtrl.text.trim();
    if (nome.isEmpty) return;
    final jaExiste = _categorias.any(
      (c) => c.nome.toLowerCase() == nome.toLowerCase(),
    );
    if (!jaExiste) {
      setState(
        () => _categorias = [..._categorias, ModeloCategoriaMusica(nome: nome)],
      );
    }
    _categoriaCtrl.clear();
  }

  void _removerCategoria(ModeloCategoriaMusica cat) {
    setState(() => _categorias = _categorias.where((c) => c != cat).toList());
  }

  Future<void> _salvar() async {
    final musica = _musicaSelecionada;
    if (musica?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma música.'),
          backgroundColor: CoresApp.erro,
        ),
      );
      return;
    }
    setState(() => _salvando = true);
    await _controlador.atualizarCategorias(
      musica!.id!,
      _categorias.map((c) => c.nome).toList(),
    );
    if (!mounted) return;
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categorias salvas com sucesso!')),
    );
    Navigator.of(context).pop();
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Autocomplete<ModeloMusica>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) return const [];
                    final q = textEditingValue.text.toLowerCase();
                    return _musicas.where(
                      (m) => m.exibicao.toLowerCase().contains(q),
                    );
                  },
                  displayStringForOption: (m) => m.exibicao,
                  fieldViewBuilder: (context, ctrl, focus, onSubmit) {
                    return TextFormField(
                      controller: ctrl,
                      focusNode: focus,
                      decoration: const InputDecoration(
                        labelText: 'Música cadastrada *',
                        hintText: 'Digite para buscar uma música',
                      ),
                    );
                  },
                  onSelected: _selecionarMusica,
                ),
                const SizedBox(height: 24),
                if (_musicaSelecionada != null) ...[
                  Text(
                    'Categorias de: ${_musicaSelecionada!.nome}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoriaCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Digite uma categoria',
                            isDense: true,
                          ),
                          onSubmitted: (_) => _adicionarCategoria(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: _adicionarCategoria,
                        color: tema.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._categorias.map(
                    (cat) => ListTile(
                      dense: true,
                      title: Text(cat.nome),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: CoresApp.erro, size: 18),
                        onPressed: () => _removerCategoria(cat),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
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
              ],
            ),
    );
  }
}
