import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_mix.dart';
import 'package:spin_flow/domain/dominio/dominio_mix.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/musica.dart';
import 'package:spin_flow/infra/config/cores_app.dart';
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
    final disponiveis = _musicasDisponiveis
        .where((m) => m.id != null && !ocupados.contains(m.id))
        .toList();

    // Prioridade 1: nome ou artista começa com o termo
    final inicio = disponiveis.where((m) =>
      m.nome.toLowerCase().startsWith(termo) ||
      m.nomeArtista.toLowerCase().startsWith(termo),
    ).toList();

    // Prioridade 2: contém o termo mas não começa com ele
    final idsInicio = inicio.map((m) => m.id).toSet();
    final contem = disponiveis.where((m) =>
      !idsInicio.contains(m.id) &&
      (m.nome.toLowerCase().contains(termo) ||
       m.nomeArtista.toLowerCase().contains(termo)),
    ).toList();

    setState(() {
      _sugestoes = [...inicio, ...contem];
      _mostraSugestoes = _sugestoes.isNotEmpty;
    });
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

  String _nomeDaMusica(int id) =>
      _musicasDisponiveis
          .firstWhere((m) => m.id == id, orElse: () => Musica(nome: '—'))
          .exibicao;

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

    final resultado = await _controlador.salvar(DominioMix(mix));
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
                  TextField(
                    controller: _buscaCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar música para adicionar...',
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
                            subtitle: m.nomeArtista.isNotEmpty
                                ? Text(
                                    m.nomeArtista,
                                    style: const TextStyle(fontSize: 11),
                                  )
                                : null,
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
                              vazio
                                  ? 'Espaço disponível'
                                  : _nomeDaMusica(musicaId),
                              style: TextStyle(
                                fontSize: 13,
                                color: vazio ? CoresApp.textoFraco : null,
                                fontStyle:
                                    vazio ? FontStyle.italic : null,
                              ),
                            ),
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
