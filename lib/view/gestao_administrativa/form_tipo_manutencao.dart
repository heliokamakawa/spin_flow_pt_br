import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_tipo_manutencao.dart';
import 'package:spin_flow/domain/dominio/dominio_tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_ativo.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormTipoManutencao extends StatefulWidget {
  final TipoManutencao? tipoManutencao;
  const FormTipoManutencao({super.key, this.tipoManutencao});

  @override
  State<FormTipoManutencao> createState() => _FormTipoManutencaoState();
}

class _FormTipoManutencaoState extends State<FormTipoManutencao> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ControladorTipoManutencao();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _ativa = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tipoManutencao;
    if (t != null) {
      _nomeController.text = t.nome;
      _descricaoController.text = t.descricao;
      _ativa = t.ativa;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final tipo = TipoManutencao(
      id: widget.tipoManutencao?.id,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      ativa: _ativa,
    );

    final resultado = await _controlador.salvar(DominioTipoManutencao(tipo));
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
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                hintText: 'Ex.: Pedal quebrado',
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
                hintText: 'Detalhes sobre este tipo de manutenção',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            CampoAtivo(
              valor: _ativa,
              aoAlterar: (v) => setState(() => _ativa = v),
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
