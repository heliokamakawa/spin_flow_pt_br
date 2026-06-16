import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_fabricante.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_ativo.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormFabricante extends StatefulWidget {
  final Fabricante? fabricante;
  const FormFabricante({super.key, this.fabricante});

  @override
  State<FormFabricante> createState() => _FormFabricanteState();
}

class _FormFabricanteState extends State<FormFabricante> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ControladorFabricante();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _nomeContatoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  bool _ativo = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final f = widget.fabricante;
    if (f != null) {
      _nomeController.text = f.nome;
      _descricaoController.text = f.descricao;
      _nomeContatoController.text = f.nomeContatoPrincipal;
      _emailController.text = f.emailContato;
      _telefoneController.text = f.telefoneContato;
      _ativo = f.ativo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _nomeContatoController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final fabricante = Fabricante(
      id: widget.fabricante?.id,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      nomeContatoPrincipal: _nomeContatoController.text.trim(),
      emailContato: _emailController.text.trim(),
      telefoneContato: _telefoneController.text.trim(),
      ativo: _ativo,
    );

    final resultado = await _controlador.salvar(fabricante);
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                hintText: 'Nome do fabricante',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? Erro.obrigatorio : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Informações sobre o fabricante',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contato',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: tema.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomeContatoController,
              decoration: const InputDecoration(
                labelText: 'Nome do contato principal',
                hintText: 'Nome da pessoa de contato',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail de contato',
                hintText: 'contato@fabricante.com',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone de contato',
                hintText: '(11) 91234-5678',
              ),
            ),
            const SizedBox(height: 24),
            CampoAtivo(
              valor: _ativo,
              aoAlterar: (v) => setState(() => _ativo = v),
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
