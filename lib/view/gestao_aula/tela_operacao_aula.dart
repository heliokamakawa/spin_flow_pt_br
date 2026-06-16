import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_operacao_aula.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/tema_app.dart';
import 'painel_frequencia_professora.dart';
import 'tela_mapa_aula.dart';

class TelaOperacaoAula extends StatefulWidget {
  const TelaOperacaoAula({super.key});

  @override
  State<TelaOperacaoAula> createState() => _TelaOperacaoAulaState();
}

class _TelaOperacaoAulaState extends State<TelaOperacaoAula> {
  final _controlador = ControladorOperacaoAula();
  List<ResumoTurmaHoje> _resumos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _controlador.listarTurmasHoje();
      if (!mounted) return;
      setState(() {
        _resumos = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar turmas: $e';
        _carregando = false;
      });
    }
  }

  void _abrirPainelFrequencia() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TelaPainelFrequenciaProfessora(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildConteudo()),
        _buildPainelBotoes(),
      ],
    );
  }

  Widget _buildConteudo() {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_resumos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Nenhuma turma agendada para hoje.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _resumos.length,
        itemBuilder: (_, i) => _CardTurma(
          resumo: _resumos[i],
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TelaMapeamentoAula(
                  turmaId: _resumos[i].turma.id!,
                  nomeTurma: _resumos[i].turma.nome,
                ),
              ),
            );
          },
          onBuscarFila: () =>
              _controlador.buscarNomesNaFila(_resumos[i].turma.id!),
        ),
      ),
    );
  }

  Widget _buildPainelBotoes() {
    return Container(
      decoration: const BoxDecoration(
        color: CoresApp.superficie,
        border: Border(top: BorderSide(color: CoresApp.borda)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _abrirPainelFrequencia,
          icon: const Icon(Icons.bar_chart),
          label: const Text('Painel de Frequência'),
          style: OutlinedButton.styleFrom(
            foregroundColor: CoresApp.primaria,
            side: const BorderSide(color: CoresApp.primaria),
          ),
        ),
      ),
    );
  }
}

class _CardTurma extends StatefulWidget {
  final ResumoTurmaHoje resumo;
  final VoidCallback onTap;
  final Future<List<String>> Function() onBuscarFila;

  const _CardTurma({
    required this.resumo,
    required this.onTap,
    required this.onBuscarFila,
  });

  @override
  State<_CardTurma> createState() => _CardTurmaState();
}

class _CardTurmaState extends State<_CardTurma> {
  void _mostrarFilaModal(BuildContext context) {
    final resumo = widget.resumo;
    final nomesFuture = widget.onBuscarFila();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cores = Theme.of(ctx).extension<CoresSemanticasApp>()!;
        return FutureBuilder<List<String>>(
          future: nomesFuture,
          builder: (ctx, snap) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people_outline, color: cores.alerta),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fila de espera · ${resumo.totalNaFila} '
                        '${resumo.totalNaFila == 1 ? 'pessoa' : 'pessoas'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  resumo.turma.nome,
                  style: TextStyle(fontSize: 13, color: cores.textoSuave),
                ),
                const SizedBox(height: 12),
                if (snap.connectionState != ConnectionState.done)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (snap.hasData && snap.data!.isNotEmpty)
                  ...snap.data!.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${e.key + 1}.',
                              style: TextStyle(
                                fontSize: 13,
                                color: cores.textoSuave,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'Nenhum aluno na fila.',
                    style: TextStyle(color: cores.textoFraco),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final turma = widget.resumo.turma;
    final dias = turma.diasSemana.map((d) => d.dbValue).join(', ');
    final totalNaFila = widget.resumo.totalNaFila;
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.fitness_center, color: Colors.white),
            ),
            title: Text(
              turma.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text('${turma.horarioInicio} · ${turma.duracaoMinutos} min'),
                Text('Sala: ${widget.resumo.nomeSala}'),
                Text('Dias: $dias'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onTap,
          ),
          if (totalNaFila > 0) ...[
            const Divider(height: 1),
            InkWell(
              onTap: () => _mostrarFilaModal(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.people_outline,
                        size: 18, color: cores.alerta),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fila de espera · $totalNaFila '
                        '${totalNaFila == 1 ? 'pessoa' : 'pessoas'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cores.alerta,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18, color: cores.textoSuave),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
