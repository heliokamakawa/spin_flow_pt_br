import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_musica.dart';
import 'package:spin_flow/model/gestao_aula/modelo_musica.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormVideoaulaMusica extends StatefulWidget {
  const FormVideoaulaMusica({super.key});

  @override
  State<FormVideoaulaMusica> createState() => _FormVideoaulaMusicaState();
}

class _FormVideoaulaMusicaState extends State<FormVideoaulaMusica> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = GetIt.I<ControladorMusica>();

  List<ModeloMusica> _musicas = [];
  int? _musicaId;
  final _urlCtrl = TextEditingController();
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarMusicas();
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final resultado = await _controlador.adicionarVideoAula(
      _musicaId!,
      _urlCtrl.text.trim(),
    );

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
                  DropdownButtonFormField<int>(
                    initialValue: _musicaId,
                    decoration: const InputDecoration(labelText: 'Música *'),
                    items: _musicas.map((m) {
                      return DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          m.exibicao,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _musicaId = v),
                    validator: (v) =>
                        v == null ? 'Selecione uma música.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Link da videoaula *',
                      hintText: 'https://youtube.com/...',
                    ),
                    keyboardType: TextInputType.url,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Link obrigatório.'
                        : null,
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
