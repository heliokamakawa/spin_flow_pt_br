import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_artista_banda.dart';
import 'package:spin_flow/model/gestao_aula/modelo_artista_banda.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';

class FormArtistaBanda extends StatefulWidget {
  final ModeloArtistaBanda? artista;
  const FormArtistaBanda({super.key, this.artista});

  @override
  State<FormArtistaBanda> createState() => _FormArtistaBandaState();
}

class _FormArtistaBandaState extends State<FormArtistaBanda> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = GetIt.I<ControladorArtistaBanda>();

  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _fotoCtrl = TextEditingController();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final a = widget.artista;
    if (a != null) {
      _nomeCtrl.text = a.nome;
      _descricaoCtrl.text = a.descricao;
      _linkCtrl.text = a.link;
      _fotoCtrl.text = a.foto;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _linkCtrl.dispose();
    _fotoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final artista = ModeloArtistaBanda(
      id: widget.artista?.id,
      nome: _nomeCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
      foto: _fotoCtrl.text.trim(),
    );

    final resultado = await _controlador.salvar(artista);
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
        title: Text(
          widget.artista == null ? 'Novo Artista ou Banda' : 'Editar Artista',
        ),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        actions: const [AcaoSairAppBar()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                hintText: 'Nome do artista ou banda',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descrição opcional',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Link',
                hintText: 'https://exemplo.com',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fotoCtrl,
              decoration: const InputDecoration(
                labelText: 'URL da foto',
                hintText: 'https://exemplo.com/foto.jpg',
              ),
              keyboardType: TextInputType.url,
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
