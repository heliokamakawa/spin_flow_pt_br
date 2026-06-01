import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_turma.dart';
import 'package:spin_flow/core/config/erro.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_turma.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/campo_ativo.dart';

class FormTurma extends StatefulWidget {
  final ModeloTurma? turma;

  const FormTurma({super.key, this.turma});

  @override
  State<FormTurma> createState() => _FormTurmaState();
}

class _FormTurmaState extends State<FormTurma> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = GetIt.I<ControladorTurma>();

  final _nomeController = TextEditingController();
  final _horarioController = TextEditingController();
  final _duracaoController = TextEditingController();

  List<ModeloSala> _salas = [];
  bool _carregando = true;
  bool _salvando = false;
  bool _ativo = true;
  List<DiaSemana> _diasSemana = [];
  int? _salaId;

  @override
  void initState() {
    super.initState();
    final turma = widget.turma;
    if (turma != null) {
      _nomeController.text = turma.nome;
      _horarioController.text = turma.horarioInicio;
      _duracaoController.text = '${turma.duracaoMinutos}';
      _diasSemana = List<DiaSemana>.from(turma.diasSemana);
      _salaId = turma.salaId;
      _ativo = turma.ativo;
    } else {
      _horarioController.text = '18:00';
      _duracaoController.text = '50';
      _diasSemana = [DiaSemana.segunda];
    }
    _carregarSalas();
  }

  Future<void> _carregarSalas() async {
    final salas = await _controlador.listarSalas();
    if (!mounted) return;
    setState(() {
      _salas = salas;
      if (_salaId == null && salas.isNotEmpty) {
        _salaId = salas.first.id;
      }
      _carregando = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _horarioController.dispose();
    _duracaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final turma = ModeloTurma(
      id: widget.turma?.id,
      nome: _nomeController.text.trim(),
      horarioInicio: _horarioController.text.trim(),
      duracaoMinutos: int.tryParse(_duracaoController.text) ?? 0,
      diasSemana: _diasSemana,
      salaId: _salaId ?? 0,
      ativo: _ativo,
    );

    final resultado = await _controlador.salvar(turma);
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
                  _buildCampoNome(),
                  const SizedBox(height: 16),
                  _buildCampoHorario(),
                  const SizedBox(height: 16),
                  _buildCampoDuracao(),
                  const SizedBox(height: 16),
                  _buildDropdownSala(),
                  const SizedBox(height: 16),
                  CampoAtivo(
                    valor: _ativo,
                    aoAlterar: (valor) => setState(() => _ativo = valor),
                  ),
                  const SizedBox(height: 16),
                  _buildSelecaoDias(),
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

  Widget _buildCampoNome() {
    return TextFormField(
      controller: _nomeController,
      decoration: const InputDecoration(
        labelText: 'Identificação *',
        hintText: 'Spinning Avançado - 18:00',
      ),
      validator: (valor) =>
          (valor == null || valor.trim().isEmpty) ? Erro.obrigatorio : null,
    );
  }

  Widget _buildCampoHorario() {
    return TextFormField(
      controller: _horarioController,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d:]')),
        LengthLimitingTextInputFormatter(5),
      ],
      decoration: const InputDecoration(
        labelText: 'Horário de início *',
        hintText: '18:00',
      ),
      validator: (valor) {
        final texto = valor?.trim() ?? '';
        if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(texto)) {
          return Erro.obrigatorio;
        }
        final partes = texto.split(':');
        final hora = int.tryParse(partes[0]) ?? -1;
        final minuto = int.tryParse(partes[1]) ?? -1;
        if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) {
          return 'Horário inválido.';
        }
        return null;
      },
    );
  }

  Widget _buildCampoDuracao() {
    return TextFormField(
      controller: _duracaoController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Duração (minutos) *',
        hintText: '50',
      ),
      validator: (valor) {
        final duracao = int.tryParse(valor ?? '');
        if (duracao == null) return Erro.obrigatorio;
        if (duracao < 1 || duracao > 180) return '1-180';
        return null;
      },
    );
  }

  Widget _buildDropdownSala() {
    return DropdownButtonFormField<int>(
      initialValue: _salaId,
      decoration: const InputDecoration(labelText: 'Sala *'),
      hint: const Text('Selecione uma sala'),
      items: _salas
          .map(
            (sala) => DropdownMenuItem(value: sala.id, child: Text(sala.nome)),
          )
          .toList(),
      onChanged: (valor) => setState(() => _salaId = valor),
      validator: (valor) => valor == null ? 'Sala é obrigatória.' : null,
    );
  }

  Widget _buildSelecaoDias() {
    return FormField<List<DiaSemana>>(
      initialValue: _diasSemana,
      validator: (_) =>
          _diasSemana.isEmpty ? 'Selecione pelo menos um dia.' : null,
      builder: (state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Dias da semana *',
            errorText: state.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: DiaSemana.values.map((dia) {
              final selecionado = _diasSemana.contains(dia);
              return FilterChip(
                label: Text(dia.rotulo),
                selected: selecionado,
                onSelected: (valor) {
                  setState(() {
                    if (valor) {
                      _diasSemana = [..._diasSemana, dia];
                    } else {
                      _diasSemana = _diasSemana
                          .where((selecionado) => selecionado != dia)
                          .toList();
                    }
                    state.didChange(_diasSemana);
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
