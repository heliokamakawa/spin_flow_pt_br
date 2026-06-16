import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_mix.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_ativo.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormMix extends StatefulWidget {
  final Mix? mix;
  const FormMix({super.key, this.mix});

  @override
  State<FormMix> createState() => _FormMixState();
}

class _FormMixState extends State<FormMix> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ControladorMix();

  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _buscaCtrl = TextEditingController();

  List<Musica> _musicasDisponiveis = [];
  List<Musica> _sugestoes = [];
  late List<int?> _posicoes;

  bool _ativo = true;
  bool _carregando = true;
  bool _salvando = false;
  bool _mostraSugestoes = false;
  String? _erroMusicas;
  int _filtroEstrelas = 0;

  @override
  void initState() {
    super.initState();
    final m = widget.mix;
    if (m != null) {
      _nomeCtrl.text = m.nome;
      _descricaoCtrl.text = m.descricao;
      _ativo = m.ativo;
      _posicoes = List<int?>.from(m.posicoes);
    } else {
      _posicoes = List<int?>.filled(Mix.totalSlots, null);
    }
    _carregarMusicas();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarMusicas() async {
    final lista = await _controlador.listarMusicasDisponiveis();
    if (!mounted) return;
    setState(() {
      _musicasDisponiveis = lista;
      _carregando = false;
    });
  }

  void _filtrar(String texto) {
    final termo = texto.trim().toLowerCase();
    if (termo.isEmpty) {
      setState(() { _sugestoes = []; _mostraSugestoes = false; });
      return;
    }
    final ocupados = _posicoes.whereType<int>().toSet();
    var disponiveis = _musicasDisponiveis
        .where((m) => m.id != null && !ocupados.contains(m.id))
        .toList();

    if (_filtroEstrelas > 0) {
      disponiveis = disponiveis.where((m) {
        if (m.mediaEstrelas == null) return false;
        final arredondada = m.mediaEstrelas!.round();
        return _filtroEstrelas == 5
            ? arredondada == 5
            : arredondada >= _filtroEstrelas;
      }).toList();
    }

    final inicio = disponiveis.where((m) =>
      m.nome.toLowerCase().startsWith(termo) ||
      m.nomeArtista.toLowerCase().startsWith(termo),
    ).toList();

    final idsInicio = inicio.map((m) => m.id).toSet();
    final contem = disponiveis.where((m) =>
      !idsInicio.contains(m.id) &&
      (m.nome.toLowerCase().contains(termo) ||
       m.nomeArtista.toLowerCase().contains(termo)),
    ).toList();

    final resultados = [...inicio, ...contem];
    if (_filtroEstrelas > 0) {
      resultados.sort((a, b) =>
          (a.mediaEstrelas ?? 0).compareTo(b.mediaEstrelas ?? 0));
    }

    setState(() {
      _sugestoes = resultados;
      _mostraSugestoes = resultados.isNotEmpty;
    });
  }

  void _selecionarEstrelas(int valor) {
    setState(() => _filtroEstrelas = _filtroEstrelas == valor ? 0 : valor);
    _filtrar(_buscaCtrl.text);
  }

  String _textoEstrelas(double media) {
    final cheia = media.round();
    return '${'★' * cheia}${'☆' * (5 - cheia)} ${media.toStringAsFixed(1)}';
  }

  Widget _buildFiltroEstrelas() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text(
            'Mín.:',
            style: TextStyle(fontSize: 12, color: CoresApp.textoSuave),
          ),
          const SizedBox(width: 6),
          for (int i = 1; i <= 5; i++)
            GestureDetector(
              onTap: () => _selecionarEstrelas(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  i <= _filtroEstrelas ? Icons.star : Icons.star_border,
                  size: 26,
                  color: i <= _filtroEstrelas ? Colors.amber : CoresApp.textoFraco,
                ),
              ),
            ),
          if (_filtroEstrelas > 0) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _selecionarEstrelas(0),
              child: const Icon(Icons.close, size: 16, color: CoresApp.textoSuave),
            ),
          ],
        ],
      ),
    );
  }

  void _adicionarMusica(Musica musica) {
    final slot = _posicoes.indexOf(null);
    if (slot == -1) return;
    setState(() {
      _posicoes[slot] = musica.id;
      _buscaCtrl.clear();
      _sugestoes = [];
      _mostraSugestoes = false;
      _erroMusicas = null;
    });
  }

  void _removerPosicao(int indice) {
    setState(() {
      final lista = List<int?>.from(_posicoes);
      lista.removeAt(indice);
      lista.add(null);
      _posicoes = lista;
    });
  }

  Musica _musicaPorId(int id) =>
      _musicasDisponiveis
          .firstWhere((m) => m.id == id, orElse: () => Musica(nome: '—'));

  Future<void> _salvar() async {
    final musicasOk = _posicoes.whereType<int>().isNotEmpty;
    if (!_formKey.currentState!.validate() || !musicasOk) {
      if (!musicasOk) {
        setState(() => _erroMusicas = 'Adicione pelo menos uma música.');
      }
      return;
    }
    setState(() => _salvando = true);

    final mix = Mix(
      id: widget.mix?.id,
      nome: _nomeCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      posicoes: _posicoes,
      ativo: _ativo,
    );

    final resultado = await _controlador.salvar(mix);
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
    final preenchidas = _posicoes.whereType<int>().length;
    final cheio = preenchidas >= Mix.totalSlots;

    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Dados gerais ─────────────────────────────────────────────
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Ex.: Mix Power Ride',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nome obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Objetivo e estilo da aula',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              CampoAtivo(
                valor: _ativo,
                aoAlterar: (v) => setState(() => _ativo = v),
              ),

              // ── Músicas ──────────────────────────────────────────────────
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Músicas do mix',
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$preenchidas / ${Mix.totalSlots}',
                    style: TextStyle(
                      fontSize: 12,
                      color: preenchidas > 0
                          ? tema.primaryColor
                          : tema.hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_carregando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                // Campo de busca
                if (!cheio) ...[
                  _buildFiltroEstrelas(),
                  TextField(
                    controller: _buscaCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar música por nome ou artista...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      suffixIcon: _buscaCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _buscaCtrl.clear();
                                _filtrar('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _filtrar,
                  ),
                  // Sugestões
                  if (_mostraSugestoes)
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                children: _sugestoes.map((m) => ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.music_note,
                                    size: 18,
                                    color: CoresApp.textoSuave,
                                  ),
                                  title: Text(m.nome),
                                  subtitle: Text(
                                    [
                                      if (m.nomeArtista.isNotEmpty) m.nomeArtista,
                                      if (m.mediaEstrelas != null)
                                        _textoEstrelas(m.mediaEstrelas!),
                                    ].join('  '),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onTap: () => _adicionarMusica(m),
                                )).toList(),
                              ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Mix completo — remova uma música para adicionar outra.',
                      style: TextStyle(fontSize: 12, color: tema.hintColor),
                    ),
                  ),

                if (_erroMusicas != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _erroMusicas!,
                      style: TextStyle(
                        fontSize: 12,
                        color: tema.colorScheme.error,
                      ),
                    ),
                  ),

                // Painel de 10 slots
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: CoresApp.borda),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: List.generate(Mix.totalSlots, (i) {
                      final musicaId = _posicoes[i];
                      final vazio = musicaId == null;
                      final ultimo = i == Mix.totalSlots - 1;

                      final musica = vazio ? null : _musicaPorId(musicaId);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: vazio
                                  ? CoresApp.borda
                                  : tema.primaryColor,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: vazio
                                      ? CoresApp.textoSuave
                                      : Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              vazio ? 'Espaço disponível' : musica!.exibicao,
                              style: TextStyle(
                                fontSize: 13,
                                color: vazio ? CoresApp.textoFraco : null,
                                fontStyle:
                                    vazio ? FontStyle.italic : null,
                              ),
                            ),
                            subtitle: musica?.mediaEstrelas != null
                                ? Text(
                                    _textoEstrelas(musica!.mediaEstrelas!),
                                    style: const TextStyle(fontSize: 11),
                                  )
                                : null,
                            trailing: vazio
                                ? null
                                : IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: tema.colorScheme.error,
                                    ),
                                    tooltip: 'Remover',
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: () => _removerPosicao(i),
                                  ),
                          ),
                          if (!ultimo) const Divider(height: 1, indent: 48),
                        ],
                      );
                    }),
                  ),
                ),
              ],

              // ── Salvar ───────────────────────────────────────────────────
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
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
                          'Salvar mix',
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
      ),
    );
  }
}
