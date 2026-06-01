import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_administrativa/controlador_sala.dart';
import 'package:spin_flow/core/config/erro.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:spin_flow/model/gestao_administrativa/modelo_sala.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_ativo.dart';

class FormSala extends StatefulWidget {
  final ModeloSala? sala;
  const FormSala({super.key, this.sala});

  @override
  State<FormSala> createState() => _FormSalaState();
}

class _FormSalaState extends State<FormSala> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = GetIt.I<ControladorSala>();

  final _nomeController = TextEditingController();
  final _filasController = TextEditingController();
  final _colunasController = TextEditingController();
  final _bikesController = TextEditingController();
  final _filaProf = TextEditingController();
  final _colunaProf = TextEditingController();
  bool _ativo = true;
  bool _salvando = false;

  // Parsed e clamped
  int get _filas => (int.tryParse(_filasController.text) ?? 4).clamp(1, 6);
  int get _colunas => (int.tryParse(_colunasController.text) ?? 5).clamp(1, 10);
  int get _bikes => (int.tryParse(_bikesController.text) ?? 1).clamp(1, 50);
  int get _profFila => int.tryParse(_filaProf.text) ?? 1;
  int get _profColuna => int.tryParse(_colunaProf.text) ?? 1;

  bool get _profDentroGrade =>
      _profFila >= 1 &&
      _profFila <= _filas &&
      _profColuna >= 1 &&
      _profColuna <= _colunas;

  int get _capacidade => _filas * _colunas;
  int get _maxBikes => _profDentroGrade ? _capacidade - 1 : _capacidade;

  @override
  void initState() {
    super.initState();
    final s = widget.sala;
    if (s != null) {
      _nomeController.text = s.nome;
      _filasController.text = '${s.numeroFilas}';
      _colunasController.text = '${s.numeroColunas}';
      _filaProf.text = '${s.filaProfessora}';
      _colunaProf.text = '${s.colunaProfessora}';
      _bikesController.text = '${s.capacidade - 1}';
      _ativo = s.ativa;
    } else {
      _filasController.text = '4';
      _colunasController.text = '5';
      _filaProf.text = '1';
      _colunaProf.text = '3';
      _bikesController.text = '19';
    }
    for (final c in [
      _filasController,
      _colunasController,
      _bikesController,
      _filaProf,
      _colunaProf,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nomeController,
      _filasController,
      _colunasController,
      _bikesController,
      _filaProf,
      _colunaProf,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final sala = ModeloSala(
      id: widget.sala?.id,
      nome: _nomeController.text.trim(),
      numeroFilas: _filas,
      numeroColunas: _colunas,
      filaProfessora: _profFila,
      colunaProfessora: _profColuna,
      ativa: _ativo,
    );

    final resultado = await _controlador.salvar(sala);
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
        title: Text(widget.sala == null ? 'Nova Sala' : 'Editar Sala'),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        actions: const [AcaoSairAppBar()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCampoNome(),
            const SizedBox(height: 24),
            _buildSecaoDimensoes(tema),
            const SizedBox(height: 24),
            _buildSecaoProfessora(tema),
            const SizedBox(height: 16),
            _buildPrevia(tema),
            const SizedBox(height: 24),
            _buildSwitch(tema),
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
        labelText: 'Nome *',
        hintText: 'Studio Alfa - Sala 1',
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? Erro.obrigatorio : null,
    );
  }

  Widget _buildSecaoDimensoes(ThemeData tema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dimensões da sala',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: tema.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCampoNumero(
                _filasController,
                'Filas *',
                min: 1,
                max: 6,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCampoNumero(
                _colunasController,
                'Colunas *',
                min: 1,
                max: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCampoNumero(
          _bikesController,
          'Quantidade de bikes *',
          min: 1,
          max: 50,
        ),
        _buildHintBikes(tema),
      ],
    );
  }

  Widget _buildSecaoProfessora(ThemeData tema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bike da professora',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: tema.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCampoNumero(_filaProf, 'Fila *', min: 1, max: 99),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCampoNumero(
                _colunaProf,
                'Coluna *',
                min: 1,
                max: 99,
              ),
            ),
          ],
        ),
        _buildHintProf(),
      ],
    );
  }

  Widget _buildCampoNumero(
    TextEditingController controller,
    String label, {
    required int min,
    required int max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final n = int.tryParse(v ?? '');
        if (n == null) return Erro.obrigatorio;
        if (n < min || n > max) return '$min–$max';
        return null;
      },
    );
  }

  Widget _buildHintBikes(ThemeData tema) {
    if (_bikesController.text.isEmpty) return const SizedBox.shrink();
    final bikes = _bikes;
    final max = _maxBikes;

    if (bikes > max) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Excede a grade — máximo $max bike${max != 1 ? "s" : ""} para $_filas×$_colunas.',
          style: const TextStyle(fontSize: 12, color: CoresApp.erro),
        ),
      );
    } else if (bikes == max) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Grade completa.',
          style: const TextStyle(fontSize: 12, color: CoresApp.sucesso),
        ),
      );
    } else {
      final livres = max - bikes;
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$livres posição${livres != 1 ? "ões" : ""} sem bike na grade.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      );
    }
  }

  Widget _buildHintProf() {
    if (!_profDentroGrade &&
        _filaProf.text.isNotEmpty &&
        _colunaProf.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Fora da grade — ajuste para fila ≤ $_filas e coluna ≤ $_colunas.',
          style: const TextStyle(fontSize: 12, color: CoresApp.erro),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPrevia(ThemeData tema) {
    final cells = _buildCells();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CoresApp.borda),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prévia da sala',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$_filas filas / $_colunas colunas',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _colunas,
              childAspectRatio: 1.3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _capacidade,
            itemBuilder: (_, i) =>
                _CelulaGrade(label: cells[i], primaryColor: tema.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            _profDentroGrade
                ? '${_bikes.clamp(0, _maxBikes)} bikes na grade + professora na fila $_profFila, coluna $_profColuna.'
                : 'Posição da professora fora da grade. Ajuste fila e coluna para exibir.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  List<String> _buildCells() {
    final profIdx = _profDentroGrade
        ? (_profFila - 1) * _colunas + _profColuna - 1
        : -1;
    final bikesVisiveis = _bikes.clamp(0, _maxBikes);
    final result = <String>[];
    int bikeCount = 1;
    for (int i = 0; i < _capacidade; i++) {
      if (i == profIdx) {
        result.add('Prof');
      } else if (bikeCount <= bikesVisiveis) {
        result.add(bikeCount.toString().padLeft(2, '0'));
        bikeCount++;
      } else {
        result.add('-');
      }
    }
    return result;
  }

  Widget _buildSwitch(ThemeData tema) {
    return CampoAtivo(
      valor: _ativo,
      aoAlterar: (v) => setState(() => _ativo = v),
    );
  }
}

class _CelulaGrade extends StatelessWidget {
  final String label;
  final Color primaryColor;

  const _CelulaGrade({required this.label, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final isProf = label == 'Prof';
    final isEmpty = label == '-';

    return Container(
      decoration: BoxDecoration(
        color: isProf
            ? primaryColor
            : isEmpty
            ? CoresApp.superficieSuave
            : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: isEmpty || isProf
            ? null
            : Border.all(color: CoresApp.bordaForte),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: isProf ? 10 : 11,
            fontWeight: isProf ? FontWeight.bold : FontWeight.normal,
            color: isProf
                ? Colors.white
                : isEmpty
                ? Colors.grey.shade400
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}
