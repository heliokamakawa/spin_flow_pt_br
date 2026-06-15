import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_operacao_aula.dart';
import 'package:spin_flow/domain/modelo/frequencia_aluno.dart';
import 'package:spin_flow/domain/modelo/turma.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

enum _Ordem { nomeAsc, nomeDesc, freqDesc, freqAsc }

class TelaPainelFrequenciaAlunos extends StatefulWidget {
  const TelaPainelFrequenciaAlunos({super.key});

  @override
  State<TelaPainelFrequenciaAlunos> createState() =>
      _TelaPainelFrequenciaAlunosState();
}

class _TelaPainelFrequenciaAlunosState
    extends State<TelaPainelFrequenciaAlunos> {
  final _controlador = ControladorOperacaoAula();

  List<Turma> _turmas = [];
  Turma? _turmaSelecionada;
  DateTime _inicio = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _fim = DateTime.now();

  List<FrequenciaAluno> _dados = [];
  bool _carregandoTurmas = true;
  bool _buscando = false;
  bool _consultaRealizada = false;
  String? _erro;
  String _filtroNome = '';
  _Ordem _ordem = _Ordem.freqDesc;

  @override
  void initState() {
    super.initState();
    _carregarTurmas();
  }

  Future<void> _carregarTurmas() async {
    try {
      final turmas = await _controlador.listarTurmasAtivas();
      if (!mounted) return;
      setState(() {
        _turmas = turmas;
        _turmaSelecionada = turmas.isNotEmpty ? turmas.first : null;
        _carregandoTurmas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar turmas.';
        _carregandoTurmas = false;
      });
    }
  }

  Future<void> _buscar() async {
    if (_turmaSelecionada == null) return;
    setState(() {
      _buscando = true;
      _erro = null;
    });
    try {
      final dados = await _controlador.buscarFrequencia(
        _turmaSelecionada!.id!,
        _inicio,
        _fim,
      );
      if (!mounted) return;
      setState(() {
        _dados = dados;
        _buscando = false;
        _consultaRealizada = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao buscar frequência: $e';
        _buscando = false;
      });
    }
  }

  List<FrequenciaAluno> get _dadosFiltradosOrdenados {
    var lista = List<FrequenciaAluno>.from(_dados);
    if (_filtroNome.isNotEmpty) {
      lista = lista
          .where(
            (f) => f.nomeAluno
                .toLowerCase()
                .contains(_filtroNome.toLowerCase()),
          )
          .toList();
    }
    switch (_ordem) {
      case _Ordem.nomeAsc:
        lista.sort((a, b) => a.nomeAluno.compareTo(b.nomeAluno));
      case _Ordem.nomeDesc:
        lista.sort((a, b) => b.nomeAluno.compareTo(a.nomeAluno));
      case _Ordem.freqDesc:
        lista.sort((a, b) => b.percentual.compareTo(a.percentual));
      case _Ordem.freqAsc:
        lista.sort((a, b) => a.percentual.compareTo(b.percentual));
    }
    return lista;
  }

  Future<void> _selecionarData(bool ehInicio) async {
    final data = await showDatePicker(
      context: context,
      initialDate: ehInicio ? _inicio : _fim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (data == null || !mounted) return;
    setState(() {
      if (ehInicio) {
        _inicio = data;
        if (_fim.isBefore(_inicio)) _fim = _inicio;
      } else {
        _fim = data;
        if (_inicio.isAfter(_fim)) _inicio = _fim;
      }
    });
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _alternarOrdemNome() => setState(() {
        _ordem = _ordem == _Ordem.nomeAsc ? _Ordem.nomeDesc : _Ordem.nomeAsc;
      });

  void _alternarOrdemFreq() => setState(() {
        _ordem = _ordem == _Ordem.freqDesc ? _Ordem.freqAsc : _Ordem.freqDesc;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFiltros(),
          const Divider(height: 1),
          Expanded(child: _buildConteudo()),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    if (_carregandoTurmas) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<Turma>(
            value: _turmaSelecionada,
            decoration: const InputDecoration(
              labelText: 'Turma *',
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(),
            ),
            items: _turmas
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.nome, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (t) => setState(() => _turmaSelecionada = t),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selecionarData(true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'De',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    child: Text(_formatarData(_inicio)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _selecionarData(false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Até',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    child: Text(_formatarData(_fim)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: (_turmaSelecionada != null && !_buscando)
                    ? _buscar
                    : null,
                icon: _buscando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search, size: 18),
                label: const Text('Buscar'),
              ),
            ],
          ),
          if (_consultaRealizada && _dados.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por nome',
                isDense: true,
                prefixIcon: Icon(Icons.search, size: 18),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (v) => setState(() => _filtroNome = v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_erro != null) {
      return Center(
        child: Text(_erro!, style: const TextStyle(color: CoresApp.erro)),
      );
    }

    if (!_consultaRealizada) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Selecione uma turma e período e clique em Buscar.',
            style: TextStyle(color: CoresApp.textoFraco),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final lista = _dadosFiltradosOrdenados;

    if (lista.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: CoresApp.textoFraco),
            SizedBox(height: 8),
            Text(
              'Nenhum dado de frequência no período selecionado.',
              style: TextStyle(color: CoresApp.textoFraco),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildCabecalho(),
        Expanded(
          child: ListView.separated(
            itemCount: lista.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: CoresApp.superficieSuave),
            itemBuilder: (_, i) => _buildLinha(lista[i]),
          ),
        ),
        _buildRodape(lista),
      ],
    );
  }

  Widget _buildCabecalho() {
    final corTexto = Theme.of(context).primaryColor;

    IconData iconeNome;
    if (_ordem == _Ordem.nomeAsc) {
      iconeNome = Icons.arrow_upward;
    } else if (_ordem == _Ordem.nomeDesc) {
      iconeNome = Icons.arrow_downward;
    } else {
      iconeNome = Icons.unfold_more;
    }

    IconData iconeFreq;
    if (_ordem == _Ordem.freqDesc) {
      iconeFreq = Icons.arrow_downward;
    } else if (_ordem == _Ordem.freqAsc) {
      iconeFreq = Icons.arrow_upward;
    } else {
      iconeFreq = Icons.unfold_more;
    }

    return Container(
      color: CoresApp.primariaSuave,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _alternarOrdemNome,
              child: Row(
                children: [
                  Text(
                    'Nome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: corTexto,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(iconeNome, size: 14, color: corTexto),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 76,
            child: Text(
              'Check-ins',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: corTexto,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: _alternarOrdemFreq,
            child: SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Freq.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: corTexto,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(iconeFreq, size: 14, color: corTexto),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinha(FrequenciaAluno f) {
    Color corPercentual;
    if (!f.percentualDisponivel) {
      corPercentual = CoresApp.textoFraco;
    } else if (f.percentual >= 75) {
      corPercentual = CoresApp.sucesso;
    } else if (f.percentual >= 50) {
      corPercentual = CoresApp.alerta;
    } else {
      corPercentual = CoresApp.erro;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              f.nomeAluno,
              style: const TextStyle(fontSize: 14, color: CoresApp.textoPrincipal),
            ),
          ),
          SizedBox(
            width: 76,
            child: Text(
              f.textoCheckins,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: CoresApp.textoSuave),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              f.percentualTexto,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: corPercentual,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRodape(List<FrequenciaAluno> lista) {
    final comDados = lista.where((f) => f.percentualDisponivel).toList();
    final media = comDados.isEmpty
        ? null
        : comDados.map((f) => f.percentual).reduce((a, b) => a + b) /
            comDados.length;

    return Container(
      color: CoresApp.superficieSuave,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${lista.length} aluno(s)',
            style: const TextStyle(fontSize: 12, color: CoresApp.textoFraco),
          ),
          if (media != null)
            Text(
              'Média: ${media.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CoresApp.textoPrincipal,
              ),
            ),
        ],
      ),
    );
  }
}