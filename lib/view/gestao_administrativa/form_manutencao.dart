import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_manutencao.dart';
import 'package:spin_flow/core/config/erro.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_bike.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_manutencao.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_tipo_manutencao.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/campo_data.dart';

class FormManutencao extends StatefulWidget {
  final ModeloManutencao? manutencao;

  const FormManutencao({super.key, this.manutencao});

  @override
  State<FormManutencao> createState() => _FormManutencaoState();
}

class _FormManutencaoState extends State<FormManutencao> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = GetIt.I<ControladorManutencao>();
  final _descricaoController = TextEditingController();

  List<ModeloBike> _bikes = [];
  List<ModeloTipoManutencao> _tipos = [];
  bool _carregando = true;
  bool _salvando = false;

  int? _bikeId;
  int? _tipoId;
  DateTime? _dataSolicitacao;
  EstadoOperacional _estado = EstadoOperacional.pendente;

  @override
  void initState() {
    super.initState();
    final manutencao = widget.manutencao;
    if (manutencao != null) {
      _bikeId = manutencao.bikeId;
      _tipoId = manutencao.tipoManutencaoId;
      _dataSolicitacao = manutencao.dataSolicitacao;
      _descricaoController.text = manutencao.descricao;
      _estado = manutencao.estadoOperacional;
    } else {
      _dataSolicitacao = DateTime.now();
    }
    _carregarDropdowns();
  }

  Future<void> _carregarDropdowns() async {
    final bikes = await _controlador.listarBikes();
    final tipos = await _controlador.listarTipos();
    if (!mounted) return;
    setState(() {
      _bikes = bikes;
      _tipos = tipos;
      _carregando = false;
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final manutencao = ModeloManutencao(
      id: widget.manutencao?.id,
      bikeId: _bikeId!,
      tipoManutencaoId: _tipoId!,
      dataSolicitacao: _dataSolicitacao!,
      descricao: _descricaoController.text.trim(),
      estadoOperacional: _estado,
    );

    final resultado = await _controlador.salvar(manutencao);
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
                  _buildDropdownBike(),
                  const SizedBox(height: 16),
                  _buildDropdownTipo(),
                  const SizedBox(height: 16),
                  CampoData(
                    rotulo: 'Data de solicitação *',
                    valor: _dataSolicitacao,
                    aoSelecionar: (data) =>
                        setState(() => _dataSolicitacao = data),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descricaoController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrição *',
                      hintText: 'Descreva o problema',
                      alignLabelWithHint: true,
                    ),
                    validator: (valor) =>
                        (valor == null || valor.trim().isEmpty)
                        ? Erro.obrigatorio
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownEstado(),
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

  Widget _buildDropdownBike() {
    return DropdownButtonFormField<int>(
      initialValue: _bikeId,
      decoration: const InputDecoration(labelText: 'Bike *'),
      hint: const Text('Selecione uma bike'),
      items: _bikes
          .map(
            (bike) => DropdownMenuItem(value: bike.id, child: Text(bike.nome)),
          )
          .toList(),
      onChanged: (valor) => setState(() => _bikeId = valor),
      validator: (valor) => valor == null ? 'Bike é obrigatória.' : null,
    );
  }

  Widget _buildDropdownTipo() {
    return DropdownButtonFormField<int>(
      initialValue: _tipoId,
      decoration: const InputDecoration(labelText: 'Tipo de manutenção *'),
      hint: const Text('Selecione um tipo'),
      items: _tipos
          .map(
            (tipo) => DropdownMenuItem(value: tipo.id, child: Text(tipo.nome)),
          )
          .toList(),
      onChanged: (valor) => setState(() => _tipoId = valor),
      validator: (valor) =>
          valor == null ? 'Tipo de manutenção é obrigatório.' : null,
    );
  }

  Widget _buildDropdownEstado() {
    return DropdownButtonFormField<EstadoOperacional>(
      initialValue: _estado,
      decoration: const InputDecoration(labelText: 'Estado operacional *'),
      items: EstadoOperacional.values
          .map(
            (estado) =>
                DropdownMenuItem(value: estado, child: Text(estado.rotulo)),
          )
          .toList(),
      onChanged: (valor) => setState(() => _estado = valor ?? _estado),
    );
  }
}
