import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spin_flow/infra/tema/cores_app.dart';
import 'package:spin_flow/controller/controlador_aluno.dart';
import 'package:spin_flow/domain/dominio/dominio_aluno.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormAluno extends StatefulWidget {
  final Aluno? aluno;
  const FormAluno({Key? key, this.aluno}) : super(key: key);

  @override
  State<FormAluno> createState() => _FormAlunoState();
}

class _FormAlunoState extends State<FormAluno> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ControladorAluno();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _dataController = TextEditingController();
  final _urlFotoController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _observacoesController = TextEditingController();

  DateTime? _dataNascimento;
  String _genero = '';
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    final a = widget.aluno;
    if (a != null) {
      _nomeController.text = a.nome;
      _emailController.text = a.email;
      _telefoneController.text = a.telefone;
      _dataController.text = _formatarData(a.dataNascimento);
      _urlFotoController.text = a.urlFoto;
      _instagramController.text = a.instagram;
      _facebookController.text = a.facebook;
      _tiktokController.text = a.tiktok;
      _observacoesController.text = a.observacoes;
      _dataNascimento = a.dataNascimento;
      _genero = a.genero;
      _ativo = a.ativo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _dataController.dispose();
    _urlFotoController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '';
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (data == null || !mounted) return;
    setState(() {
      _dataNascimento = data;
      _dataController.text = _formatarData(data);
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final aluno = Aluno(
      id: widget.aluno?.id,
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim(),
      dataNascimento: _dataNascimento,
      genero: _genero,
      urlFoto: _urlFotoController.text.trim(),
      instagram: _instagramController.text.trim(),
      facebook: _facebookController.text.trim(),
      tiktok: _tiktokController.text.trim(),
      observacoes: _observacoesController.text.trim(),
      ativo: _ativo,
    );

    final erro = await _controlador.salvar(DominioAluno(aluno));
    if (!mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: CoresApp.erro),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            // ── Dados obrigatórios ────────────────────────────────────────
            TextFormField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                hintText: 'Nome completo',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nome obrigatório.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail *',
                hintText: 'exemplo@email.com',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'E-mail obrigatório.';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'E-mail inválido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [_MascaraTelefone()],
              decoration: const InputDecoration(
                labelText: 'Telefone *',
                hintText: '(11) 99999-9999',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Telefone obrigatório.';
                final digitos = v.replaceAll(RegExp(r'\D'), '');
                if (digitos.length < 10) return 'Telefone incompleto — informe DDD + número.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dataController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data de nascimento *',
                hintText: 'DD/MM/AAAA',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: _selecionarData,
                ),
              ),
              onTap: _selecionarData,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Data de nascimento obrigatória.' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _genero.isEmpty ? null : _genero,
              hint: const Text('Selecione'),
              decoration: const InputDecoration(labelText: 'Gênero *'),
              items: const [
                DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                DropdownMenuItem(value: 'outro', child: Text('Outro')),
              ],
              onChanged: (v) => setState(() => _genero = v ?? ''),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Gênero obrigatório.' : null,
            ),

            // ── Dados opcionais ───────────────────────────────────────────
            const SizedBox(height: 20),
            TextFormField(
              controller: _urlFotoController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL da foto',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram',
                hintText: '@usuario',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _facebookController,
              decoration: const InputDecoration(
                labelText: 'Facebook',
                hintText: 'Nome de perfil',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tiktokController,
              decoration: const InputDecoration(
                labelText: 'TikTok',
                hintText: '@usuario',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacoesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Perfil de uso, preferências, restrições...',
                alignLabelWithHint: true,
              ),
            ),

            // ── Status ────────────────────────────────────────────────────
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aluno ativo'),
              subtitle: const Text('Desative para inativar sem excluir'),
              value: _ativo,
              onChanged: (v) => setState(() => _ativo = v),
              contentPadding: EdgeInsets.zero,
            ),

            // ── Salvar ────────────────────────────────────────────────────
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _salvar,
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Máscara de telefone ────────────────────────────────────────────────────────

class _MascaraTelefone extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digitos.length && i < 11; i++) {
      if (i == 0) buf.write('(');
      if (i == 2) buf.write(') ');
      // celular: X dígitos no prefixo; fixo: 4 dígitos
      if (i == (digitos.length == 11 ? 7 : 6)) buf.write('-');
      buf.write(digitos[i]);
    }
    final texto = buf.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
