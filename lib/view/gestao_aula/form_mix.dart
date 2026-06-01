import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_mix.dart';
import 'package:spin_flow/model/gestao_aula/modelo_mix.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormMix extends StatefulWidget {
  final ModeloMix? mix;
  const FormMix({super.key, this.mix});

  @override
  State<FormMix> createState() => _FormMixState();
}

class _FormMixState extends State<FormMix> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = GetIt.I<ControladorMix>();

  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  List<ModeloMusica> _musicasDisponiveis = [];
  int? _musicaEscolhida;
  late List<int?> _posicoes;

  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mix;
    if (m != null) {
      _nomeCtrl.text = m.nome;
      _descricaoCtrl.text = m.descricao;
      _posicoes = List<int?>.from(m.posicoes);
    } else {
      _posicoes = List<int?>.filled(ModeloMix.totalSlots, null);
    }
    _carregarMusicas();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
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

  void _adicionarMusica() {
    if (_musicaEscolhida == null) return;
    final jaEsta = _posicoes.contains(_musicaEscolhida);
    if (jaEsta) return;
    final slotVazio = _posicoes.indexOf(null);
    if (slotVazio == -1) return;
    setState(() {
      _posicoes[slotVazio] = _musicaEscolhida;
      _musicaEscolhida = null;
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

  String _nomeDaMusica(int musicaId) {
    final musica = _musicasDisponiveis.firstWhere(
      (m) => m.id == musicaId,
      orElse: () => ModeloMusica(nome: '—', artistaId: null),
    );
    return musica.exibicao;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final mix = ModeloMix(
      id: widget.mix?.id,
      nome: _nomeCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      posicoes: _posicoes,
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
    final musicasNaoAdicionadas = _musicasDisponiveis
        .where((m) => m.id != null && !_posicoes.contains(m.id))
        .toList();

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
                      hintText: 'Ex.: Mix Performance - Subida e Sprint',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descricaoCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Objetivo e estilo da aula',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Músicas do mix',
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _musicaEscolhida,
                          decoration: const InputDecoration(
                            hintText: 'Escolha uma música',
                            isDense: true,
                          ),
                          items: musicasNaoAdicionadas.map((m) {
                            return DropdownMenuItem(
                              value: m.id,
                              child: Text(
                                m.exibicao,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _musicaEscolhida = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _adicionarMusica,
                        child: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ModeloMix.totalSlots} espaços fixos para músicas',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(ModeloMix.totalSlots, (i) {
                    final musicaId = _posicoes[i];
                    final vazio = musicaId == null;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: vazio
                            ? Colors.grey[300]
                            : tema.primaryColor,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            color: vazio ? Colors.grey[600] : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        vazio ? 'Espaço disponível' : _nomeDaMusica(musicaId),
                        style: TextStyle(
                          color: vazio ? Colors.grey[400] : null,
                          fontStyle: vazio ? FontStyle.italic : null,
                        ),
                      ),
                      trailing: vazio
                          ? null
                          : TextButton(
                              onPressed: () => _removerPosicao(i),
                              child: Text(
                                'remover',
                                style: TextStyle(
                                  color: CoresApp.erro,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    );
                  }),
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
    );
  }
}
