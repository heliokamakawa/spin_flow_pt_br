import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spin_flow/controller/controlador_bike.dart';
import 'package:spin_flow/domain/dominio/dominio_bike.dart';
import 'package:spin_flow/domain/modelo/bike.dart';
import 'package:spin_flow/domain/modelo/fabricante.dart';
import 'package:spin_flow/domain/modelo/posicao_bike.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_ativo.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class FormBike extends StatefulWidget {
  final Bike? bike;
  const FormBike({super.key, this.bike});

  @override
  State<FormBike> createState() => _FormBikeState();
}

class _FormBikeState extends State<FormBike> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ControladorBike();

  final _nomeController = TextEditingController();
  final _serieController = TextEditingController();
  bool _ativo = true;
  bool _salvando = false;
  bool _carregando = true;

  DateTime? _dataCadastro;
  int? _fabricanteId;
  List<Fabricante> _fabricantes = [];
  List<PosicaoBike> _todasPosicoes = [];
  PosicaoBike? _posicaoSelecionada;

  @override
  void initState() {
    super.initState();
    final b = widget.bike;
    if (b != null) {
      _nomeController.text = b.nome;
      _serieController.text = b.numeroSerie;
      _dataCadastro = b.dataCadastro;
      _fabricanteId = b.fabricanteId;
      _ativo = b.ativa;
    }
    _inicializar();
  }

  Future<void> _inicializar() async {
    final resultados = await Future.wait([
      _controlador.listarFabricantes(),
      _controlador.listarPosicoes(),
      if (widget.bike?.id != null)
        _controlador.buscarPosicaoDaBike(widget.bike!.id!),
    ]);

    if (!mounted) return;
    setState(() {
      _fabricantes = resultados[0] as List<Fabricante>;
      _todasPosicoes = resultados[1] as List<PosicaoBike>;
      if (resultados.length > 2) {
        _posicaoSelecionada = resultados[2] as PosicaoBike?;
      }
      _carregando = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _serieController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataCadastro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data de cadastro é obrigatória.'),
          backgroundColor: CoresApp.erro,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final bike = Bike(
      id: widget.bike?.id,
      nome: _nomeController.text.trim(),
      numeroSerie: _serieController.text.trim(),
      fabricanteId: _fabricanteId!,
      dataCadastro: _dataCadastro!,
      ativa: _ativo,
    );

    final resultado = await _controlador.salvar(
      DominioBike(bike),
      posicao: _posicaoSelecionada,
      gerenciarPosicao: true,
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

  Future<void> _selecionarPosicao() async {
    final selecionada = await showDialog<PosicaoBike?>(
      context: context,
      builder: (_) => _DialogPosicao(
        posicoes: _todasPosicoes,
        posicaoAtual: _posicaoSelecionada,
      ),
    );
    if (!mounted) return;
    if (selecionada == null && _posicaoSelecionada == null) return;
    setState(() => _posicaoSelecionada = selecionada);
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
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome *',
                      hintText: 'Bike 01',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? Erro.obrigatorio : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serieController,
                    decoration: const InputDecoration(
                      labelText: 'Número de série *',
                      hintText: 'PSI-BK-0001',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? Erro.obrigatorio : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _fabricanteId,
                    decoration: const InputDecoration(labelText: 'Fabricante *'),
                    items: _fabricantes
                        .map((f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(f.nome),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _fabricanteId = v),
                    validator: (v) => v == null ? Erro.obrigatorio : null,
                  ),
                  const SizedBox(height: 16),
                  _CampoDataCadastro(
                    valor: _dataCadastro,
                    aoSelecionar: (d) => setState(() => _dataCadastro = d),
                  ),
                  const SizedBox(height: 24),
                  CampoAtivo(
                    valor: _ativo,
                    aoAlterar: (v) => setState(() => _ativo = v),
                  ),
                  const SizedBox(height: 24),
                  _SecaoPosicao(
                    posicao: _posicaoSelecionada,
                    tema: tema,
                    onSelecionar: _selecionarPosicao,
                    onRemover: () => setState(() => _posicaoSelecionada = null),
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

class _CampoDataCadastro extends StatelessWidget {
  final DateTime? valor;
  final void Function(DateTime) aoSelecionar;

  static final _formato = DateFormat('dd/MM/yyyy', 'pt_BR');

  const _CampoDataCadastro({required this.valor, required this.aoSelecionar});

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: valor,
      validator: (v) => v == null ? Erro.obrigatorio : null,
      builder: (state) => InkWell(
        onTap: () async {
          final hoje = DateTime.now();
          final selecionada = await showDatePicker(
            context: context,
            initialDate: state.value ?? hoje,
            firstDate: DateTime(2000),
            lastDate: hoje,
            locale: const Locale('pt', 'BR'),
          );
          if (selecionada != null) {
            state.didChange(selecionada);
            aoSelecionar(selecionada);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Data de cadastro *',
            errorText: state.errorText,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(
            state.value != null
                ? _formato.format(state.value!)
                : 'dd/mm/aaaa',
            style: TextStyle(
              color: state.value != null ? null : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecaoPosicao extends StatelessWidget {
  final PosicaoBike? posicao;
  final ThemeData tema;
  final VoidCallback onSelecionar;
  final VoidCallback onRemover;

  const _SecaoPosicao({
    required this.posicao,
    required this.tema,
    required this.onSelecionar,
    required this.onRemover,
  });

  String get _labelPosicao => posicao != null
      ? 'Fila ${posicao!.fila + 1}, Coluna ${posicao!.coluna + 1}'
      : 'Sem posição na grade';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CoresApp.borda),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posição na grade (opcional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: tema.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                posicao != null
                    ? Icons.grid_on
                    : Icons.grid_off_outlined,
                size: 18,
                color: posicao != null
                    ? tema.primaryColor
                    : CoresApp.textoFraco,
              ),
              const SizedBox(width: 8),
              Text(
                _labelPosicao,
                style: TextStyle(
                  color: posicao != null
                      ? CoresApp.textoPrincipal
                      : CoresApp.textoFraco,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onSelecionar,
                icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: Text(posicao != null ? 'Alterar' : 'Selecionar'),
              ),
              if (posicao != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onRemover,
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  label: const Text('Remover'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CoresApp.erro,
                    side: const BorderSide(color: CoresApp.erro),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogPosicao extends StatelessWidget {
  final List<PosicaoBike> posicoes;
  final PosicaoBike? posicaoAtual;

  const _DialogPosicao({
    required this.posicoes,
    required this.posicaoAtual,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return AlertDialog(
      title: const Text('Selecionar posição'),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: posicoes.length,
          itemBuilder: (_, i) {
            final p = posicoes[i];
            final ehAtual = posicaoAtual != null &&
                p.fila == posicaoAtual!.fila &&
                p.coluna == posicaoAtual!.coluna;
            final ocupadaPorOutra = p.bikeId != null && !ehAtual;
            final label =
                'Fila ${p.fila + 1}, Coluna ${p.coluna + 1}';
            final sublabel = ehAtual
                ? 'posição atual'
                : ocupadaPorOutra
                    ? 'ocupada — ${p.bikeNome}'
                    : 'livre';

            return ListTile(
              enabled: !ocupadaPorOutra,
              leading: Icon(
                ehAtual
                    ? Icons.check_circle
                    : ocupadaPorOutra
                        ? Icons.block
                        : Icons.radio_button_unchecked,
                color: ehAtual
                    ? tema.primaryColor
                    : ocupadaPorOutra
                        ? CoresApp.textoFraco
                        : CoresApp.sucesso,
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: ocupadaPorOutra ? CoresApp.textoFraco : null,
                ),
              ),
              subtitle: Text(
                sublabel,
                style: TextStyle(
                  fontSize: 12,
                  color: ehAtual
                      ? tema.primaryColor
                      : ocupadaPorOutra
                          ? CoresApp.textoFraco
                          : CoresApp.sucesso,
                ),
              ),
              onTap: ocupadaPorOutra
                  ? null
                  : () => Navigator.of(context).pop(p),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
