import 'package:flutter/material.dart';
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
    final aluno = widget.aluno;
    if (aluno != null) {
      _nomeController.text = aluno.nome;
      _emailController.text = aluno.email;
      _telefoneController.text = aluno.telefone;
      _urlFotoController.text = aluno.urlFoto;
      _instagramController.text = aluno.instagram;
      _facebookController.text = aluno.facebook;
      _tiktokController.text = aluno.tiktok;
      _observacoesController.text = aluno.observacoes;
      _dataNascimento = aluno.dataNascimento;
      _genero = aluno.genero;
      _ativo = aluno.ativo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _urlFotoController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final aluno = Aluno(
      id: widget.aluno?.id,
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      dataNascimento: _dataNascimento,
      genero: _genero,
      urlFoto: _urlFotoController.text,
      instagram: _instagramController.text,
      facebook: _facebookController.text,
      tiktok: _tiktokController.text,
      observacoes: _observacoesController.text,
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
    Navigator.of(context).pop(); // Volta para a lista após salvar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              const SizedBox(height: 12),
              InputDatePickerFormField(
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                fieldLabelText: 'Data de Nascimento',
                initialDate: _dataNascimento ?? DateTime(2000, 1, 1),
                onDateSubmitted: (date) =>
                    setState(() => _dataNascimento = date),
                onDateSaved: (date) => setState(() => _dataNascimento = date),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _genero.isEmpty ? null : _genero,
                decoration: const InputDecoration(labelText: 'Gênero'),
                items: const [
                  DropdownMenuItem(
                    value: 'masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                  DropdownMenuItem(value: 'outro', child: Text('Outro')),
                ],
                onChanged: (val) => setState(() => _genero = val ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlFotoController,
                decoration: const InputDecoration(labelText: 'URL da Foto'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(labelText: 'Instagram'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _facebookController,
                decoration: const InputDecoration(labelText: 'Facebook'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tiktokController,
                decoration: const InputDecoration(labelText: 'TikTok'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Ativo'),
                  Switch(
                    value: _ativo,
                    onChanged: (val) => setState(() => _ativo = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
