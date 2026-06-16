import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_checkin_aluno.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/musica_checkin.dart';
import 'package:spin_flow/domain/modelo/nivel_aluno.dart';
import 'package:spin_flow/domain/modelo/painel_aluno.dart';
import 'package:spin_flow/controller/sessao_usuario.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/tema_app.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/painel_mix.dart';
import 'package:spin_flow/domain/modelo/situacao_checkin_aluno.dart';
import 'package:spin_flow/view/checkin/tela_checkin.dart';

class TelaDashboardCheckin extends StatefulWidget {
  const TelaDashboardCheckin({super.key});

  @override
  State<TelaDashboardCheckin> createState() => _TelaDashboardCheckinState();
}

class _TelaDashboardCheckinState extends State<TelaDashboardCheckin>
    with SingleTickerProviderStateMixin {
  final _controlador = ControladorCheckinAluno();
  late final TabController _tabController;

  int? _alunoId;

  // ── Aba Check-in ──────────────────────────────────────────────────────────
  List<SituacaoCheckinAluno> _situacoes = [];
  bool _carregandoCheckin = true;
  String? _erroCheckin;

  // ── Aba Painel ────────────────────────────────────────────────────────────
  PainelAluno? _painel;
  bool _carregandoPainel = true;
  String? _erroPainel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_aoMudarAba);
    _inicializar();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_aoMudarAba)
      ..dispose();
    super.dispose();
  }

  void _aoMudarAba() {
    if (!_tabController.indexIsChanging) return;
    if (_tabController.index == 1 && _painel == null && _erroPainel == null) {
      _carregarPainel();
    }
  }

  Future<void> _inicializar() async {
    final alunoId = SessaoUsuario.alunoId;
    if (alunoId == null) {
      setState(() {
        _erroCheckin = 'Sessão expirada.';
        _carregandoCheckin = false;
        _carregandoPainel = false;
      });
      return;
    }
    _alunoId = alunoId;
    await Future.wait([_carregarCheckin(), _carregarPainel()]);
  }

  Future<void> _carregarCheckin() async {
    final alunoId = _alunoId;
    if (alunoId == null) return;
    setState(() {
      _carregandoCheckin = true;
      _erroCheckin = null;
    });
    try {
      final lista = await _controlador.listarTurmasHoje(alunoId);
      if (!mounted) return;
      setState(() {
        _situacoes = lista;
        _carregandoCheckin = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroCheckin = 'Erro ao carregar turmas: $e';
        _carregandoCheckin = false;
      });
    }
  }

  Future<void> _carregarPainel() async {
    final alunoId = _alunoId;
    if (alunoId == null) return;
    setState(() {
      _carregandoPainel = true;
      _erroPainel = null;
    });
    try {
      final painel = await _controlador.buscarPainelAluno(alunoId);
      if (!mounted) return;
      setState(() {
        _painel = painel;
        _carregandoPainel = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroPainel = 'Erro ao carregar painel: $e';
        _carregandoPainel = false;
      });
    }
  }

  Future<void> _aoTocarCard(SituacaoCheckinAluno s) async {
    switch (s.status) {
      case StatusCheckinAluno.conflito:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Você já tem check-in em ${s.nomeTurmaConflito ?? "outra turma"} neste horário.',
          ),
        ));

      case StatusCheckinAluno.janelaFechada:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Reserva disponível 30 min antes do início.'),
        ));

      case StatusCheckinAluno.confirmado:
        await _cancelarCheckinDaLista(s);

      default:
        await Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => TelaCheckin(
                turmaId: s.turma.id!,
                alunoId: _alunoId!,
              ),
            ))
            .then((_) => _carregarCheckin());
    }
  }

  Future<void> _sairDaFilaDaLista(SituacaoCheckinAluno s) async {
    final filaId = s.filaId;
    if (filaId == null) return;

    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.turma.nome),
        content: const Text('Sair da fila de espera desta aula?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: CoresApp.alerta),
            child: const Text('Sair da Fila'),
          ),
        ],
      ),
    );
    if (confirma != true || !mounted) return;

    final resultado = await _controlador.sairDaFila(filaId);
    if (!mounted) return;
    if (resultado.sucesso) {
      await _carregarCheckin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado.mensagemErro!)),
      );
    }
  }

  Future<void> _cancelarCheckinDaLista(SituacaoCheckinAluno s) async {
    final id = s.checkinId;
    if (id == null) return;

    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.turma.nome),
        content: const Text('Cancelar sua reserva nesta aula?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: CoresApp.erro),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (confirma != true || !mounted) return;

    final resultado = await _controlador.cancelarMinha(id);
    if (!mounted) return;
    if (resultado.sucesso) {
      await _carregarCheckin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado.mensagemErro!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bike), text: 'Check-in'),
            Tab(icon: Icon(Icons.person), text: 'Meu Painel'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAbaCheckin(context),
          _buildAbaPainel(context),
        ],
      ),
    );
  }

  // ── Aba Check-in ──────────────────────────────────────────────────────────

  Widget _buildAbaCheckin(BuildContext context) {
    if (_carregandoCheckin) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erroCheckin != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erroCheckin!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _inicializar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_situacoes.isEmpty) {
      final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 48, color: cores.textoFraco),
            const SizedBox(height: 12),
            Text('Nenhuma aula hoje.',
                style: TextStyle(color: cores.textoSuave)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _carregarCheckin,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregarCheckin,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _situacoes.length,
        itemBuilder: (_, i) => _CardCheckin(
          situacao: _situacoes[i],
          alunoId: _alunoId!,
          onTap: () => _aoTocarCard(_situacoes[i]),
          onSairFila: () => _sairDaFilaDaLista(_situacoes[i]),
        ),
      ),
    );
  }

  // ── Aba Painel ────────────────────────────────────────────────────────────

  Widget _buildAbaPainel(BuildContext context) {
    if (_carregandoPainel && _painel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erroPainel != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erroPainel!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _carregarPainel,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_painel == null) {
      return const Center(child: Text('Nenhum dado disponível.'));
    }
    return RefreshIndicator(
      onRefresh: _carregarPainel,
      child: _AbaPainelAluno(
        painel: _painel!,
        alunoId: _alunoId!,
        onAvaliar: (musicaId, nota) =>
            _controlador.avaliarMusica(_alunoId!, musicaId, nota)
                .then((_) => _carregarPainel()),
        onBuscarMix: (mixId) =>
            _controlador.buscarMixComAvaliacoes(mixId, _alunoId!),
      ),
    );
  }

}

// ── Aba Painel — conteúdo ────────────────────────────────────────────────────

enum _ModoMix { top, preferidas, avaliacao }

class _AbaPainelAluno extends StatefulWidget {
  final PainelAluno painel;
  final int alunoId;
  final Future<void> Function(int musicaId, int nota) onAvaliar;
  final Future<MixCheckin?> Function(int mixId) onBuscarMix;

  const _AbaPainelAluno({
    required this.painel,
    required this.alunoId,
    required this.onAvaliar,
    required this.onBuscarMix,
  });

  @override
  State<_AbaPainelAluno> createState() => _AbaPainelAlunoState();
}

class _AbaPainelAlunoState extends State<_AbaPainelAluno> {
  _ModoMix _modoMix = _ModoMix.top;
  MixCheckin? _mixAtual;
  bool _carregandoMixBusca = false;
  final Map<int, int> _avaliacoesAvaliacao = {};

  @override
  void initState() {
    super.initState();
    _mixAtual = widget.painel.ultimoMix;
  }

  @override
  void didUpdateWidget(_AbaPainelAluno oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Só sincroniza quando o painel foi recarregado de fato (objeto novo).
    // Rebuilds do pai sem recarga não devem sobrescrever _mixAtual atualizado
    // localmente por _aoAvaliarNoMix.
    if (!identical(widget.painel, oldWidget.painel) &&
        _mixAtual?.mixId == oldWidget.painel.ultimoMix?.mixId) {
      setState(() => _mixAtual = widget.painel.ultimoMix);
    }
  }

  @override
  Widget build(BuildContext context) {
    final painel = widget.painel;
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Nível do aluno ────────────────────────────────────────────────
        _CartaoNivel(semanasSeguidas: painel.indicadores.semanasSeguidas),
        const SizedBox(height: 12),

        // ── Participação ──────────────────────────────────────────────────
        _secao(
          context,
          icone: Icons.bar_chart,
          titulo: 'Aulas Realizadas',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _contadorParticipacao('Semana', painel.estatisticas.semana, cores),
              _divisorVertical(),
              _contadorParticipacao('Mês', painel.estatisticas.mes, cores),
              _divisorVertical(),
              _contadorParticipacao('Ano', painel.estatisticas.ano, cores),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Indicadores ───────────────────────────────────────────────────
        _secao(
          context,
          icone: Icons.insights,
          titulo: 'Indicadores',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _contadorParticipacao(
                        'Aulas este mês', painel.indicadores.aulasMes, cores),
                  ),
                  _divisorVertical(),
                  Expanded(
                    child: _contadorParticipacao('Semanas ativas (3 meses)',
                        painel.indicadores.semanasAtivas, cores),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _linhaIndicador(
                cores,
                titulo: 'Total de aulas',
                detalhe:
                    '${painel.indicadores.totalTresMeses} nos últimos 3 meses',
              ),
              const SizedBox(height: 8),
              _linhaIndicador(
                cores,
                titulo: 'Sequência atual',
                detalhe: _detalheSequencia(painel.indicadores.sequenciaAtual),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Avaliação de Mix ──────────────────────────────────────────────
        _secao(
          context,
          icone: Icons.music_note,
          titulo: 'Avaliação de Mix',
          child: _buildSecaoMix(painel, cores),
        ),
      ],
    );
  }

  Widget _buildSecaoMix(PainelAluno painel, CoresSemanticasApp cores) {
    final mix = _mixAtual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seletor de modo — sempre visível
        SegmentedButton<_ModoMix>(
          segments: const [
            ButtonSegment(
              value: _ModoMix.top,
              label: Text('Top 5'),
              icon: Icon(Icons.star),
            ),
            ButtonSegment(
              value: _ModoMix.preferidas,
              label: Text('Preferidas'),
              icon: Icon(Icons.favorite),
            ),
            ButtonSegment(
              value: _ModoMix.avaliacao,
              label: Text('Avaliação'),
              icon: Icon(Icons.rate_review_outlined),
            ),
          ],
          selected: {_modoMix},
          onSelectionChanged: (s) => setState(() => _modoMix = s.first),
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),

        const SizedBox(height: 14),

        if (_modoMix == _ModoMix.avaliacao)
          _buildAvaliacao(painel, mix, cores)
        else if (mix == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Nenhum mix encontrado nas suas aulas.',
              style: TextStyle(color: cores.textoFraco, fontSize: 14),
            ),
          )
        else ...[
          // Cabeçalho do mix para Top 5 / Preferidas
          Row(
            children: [
              Icon(Icons.music_note, size: 16, color: cores.textoSuave),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  mix.nomeMix,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildConteudoModo(mix, cores),
        ],
      ],
    );
  }

  Widget _buildConteudoModo(MixCheckin mix, CoresSemanticasApp cores) {
    switch (_modoMix) {
      case _ModoMix.top:       return _buildTop5(mix, cores);
      case _ModoMix.preferidas: return _buildPreferidas(mix, cores);
      case _ModoMix.avaliacao:  return const SizedBox.shrink();
    }
  }

  Widget _buildAvaliacao(
    PainelAluno painel,
    MixCheckin? mix,
    CoresSemanticasApp cores,
  ) {
    final mixSelecionado = mix != null
        ? painel.mixesDisponiveis
            .where((m) => m.id == mix.mixId)
            .firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _carregandoMixBusca
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : DropdownMenu<Mix>(
                key: ValueKey(mix?.mixId),
                width: double.infinity,
                initialSelection: mixSelecionado,
                hintText: 'Selecionar mix...',
                enableFilter: true,
                leadingIcon: const Icon(Icons.search, size: 18),
                inputDecorationTheme: const InputDecorationTheme(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                dropdownMenuEntries: painel.mixesDisponiveis
                    .map((m) => DropdownMenuEntry<Mix>(value: m, label: m.nome))
                    .toList(),
                onSelected: (m) {
                  if (m?.id != null) _selecionarMix(m!.id!);
                },
              ),

        if (mix == null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Nenhum mix encontrado nas suas aulas.',
              style: TextStyle(color: cores.textoFraco, fontSize: 14),
            ),
          )
        else ...[
          const SizedBox(height: 12),
          ...mix.musicas
              .map((m) => _linhaMusicaParaAvaliar(m, cores)),
        ],
      ],
    );
  }

  Widget _linhaMusicaParaAvaliar(MusicaCheckin m, CoresSemanticasApp cores) {
    final nota = _avaliacoesAvaliacao[m.musicaId] ?? m.avaliacao ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (m.nomeArtista.isNotEmpty)
                  Text(
                    m.nomeArtista,
                    style: TextStyle(fontSize: 13, color: cores.textoFraco),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final valor = i + 1;
              return GestureDetector(
                onTap: () {
                  setState(() => _avaliacoesAvaliacao[m.musicaId] = valor);
                  _aoAvaliarNoMix(m.musicaId, valor);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    valor <= nota ? Icons.star : Icons.star_border,
                    color: valor <= nota ? Colors.amber : cores.textoFraco,
                    size: 20,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTop5(MixCheckin mix, CoresSemanticasApp cores) {
    final avaliadas = mix.musicas
        .where((m) => m.avaliacao != null)
        .toList()
      ..sort((a, b) => b.avaliacao!.compareTo(a.avaliacao!));
    final top = avaliadas.take(5).toList();

    if (top.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nenhuma música avaliada neste mix ainda.',
          style: TextStyle(color: cores.textoFraco, fontSize: 14),
        ),
      );
    }
    return Column(children: top.map((m) => _linhaMusicaAvaliada(m, cores)).toList());
  }

  Widget _buildPreferidas(MixCheckin mix, CoresSemanticasApp cores) {
    final preferidas = mix.musicas.where((m) => m.avaliacao == 5).toList();

    if (preferidas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nenhuma música preferida ainda. Use a aba Avaliação para avaliar.',
          style: TextStyle(color: cores.textoFraco, fontSize: 14),
        ),
      );
    }

    return Column(
      children: preferidas
          .map((m) => _linhaMusicaInterativa(m, cores))
          .toList(),
    );
  }

  Widget _linhaMusicaInterativa(MusicaCheckin m, CoresSemanticasApp cores) {
    final nota = m.avaliacao ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (m.nomeArtista.isNotEmpty)
                  Text(
                    m.nomeArtista,
                    style: TextStyle(fontSize: 13, color: cores.textoFraco),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final valor = i + 1;
              final preenchida = valor <= nota;
              return GestureDetector(
                onTap: () => _aoAvaliarNoMix(m.musicaId, valor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    preenchida ? Icons.star : Icons.star_border,
                    color: preenchida ? Colors.amber : cores.textoFraco,
                    size: 20,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _linhaMusicaAvaliada(MusicaCheckin m, CoresSemanticasApp cores) {
    final nota = m.avaliacao ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (m.nomeArtista.isNotEmpty)
                  Text(
                    m.nomeArtista,
                    style: TextStyle(fontSize: 13, color: cores.textoFraco),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final preenchida = (i + 1) <= nota;
              return Icon(
                preenchida ? Icons.star : Icons.star_border,
                color: preenchida ? Colors.amber : cores.textoFraco,
                size: 16,
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarMix(int mixId) async {
    setState(() => _carregandoMixBusca = true);
    final mix = await widget.onBuscarMix(mixId);
    if (!mounted) return;
    setState(() {
      _carregandoMixBusca = false;
      if (mix != null) {
        _mixAtual = mix;
        _avaliacoesAvaliacao.clear();
      }
    });
  }

  Future<void> _aoAvaliarNoMix(int musicaId, int nota) async {
    await widget.onAvaliar(musicaId, nota);
    final mix = _mixAtual;
    if (mix == null || !mounted) return;
    final mixAtualizado = await widget.onBuscarMix(mix.mixId);
    if (!mounted) return;
    setState(() {
      if (mixAtualizado != null) _mixAtual = mixAtualizado;
    });
  }

  Widget _secao(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 18),
                const SizedBox(width: 6),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _contadorParticipacao(
    String label,
    int valor,
    CoresSemanticasApp cores,
  ) {
    return Column(
      children: [
        Text(
          '$valor',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: cores.textoSuave),
        ),
      ],
    );
  }

  Widget _divisorVertical() =>
      const SizedBox(height: 40, child: VerticalDivider());

  Widget _linhaIndicador(
    CoresSemanticasApp cores, {
    required String titulo,
    required String detalhe,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: cores.textoFraco.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            detalhe,
            style: TextStyle(fontSize: 14, color: cores.textoSuave),
          ),
        ],
      ),
    );
  }

  String _detalheSequencia(int dias) {
    if (dias == 0) return 'Nenhuma aula recente';
    return '$dias ${dias == 1 ? 'dia consecutivo' : 'dias consecutivos'}';
  }

}

// ── Card Check-in ─────────────────────────────────────────────────────────────

class _CardCheckin extends StatefulWidget {
  final SituacaoCheckinAluno situacao;
  final int alunoId;
  final VoidCallback onTap;
  final VoidCallback onSairFila;

  const _CardCheckin({
    required this.situacao,
    required this.alunoId,
    required this.onTap,
    required this.onSairFila,
  });

  @override
  State<_CardCheckin> createState() => _CardCheckinState();
}

class _CardCheckinState extends State<_CardCheckin> {
  final _controlador = ControladorCheckinAluno();

  void _mostrarFilaModal(BuildContext context) {
    final s = widget.situacao;
    final nomesFuture = _controlador.buscarNomesNaFila(s.turma.id!);
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
                        'Fila de espera · ${s.totalNaFila} '
                        '${s.totalNaFila == 1 ? 'pessoa' : 'pessoas'}',
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
                  s.turma.nome,
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
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final s = widget.situacao;
    final turma = s.turma;
    final mix = s.mix;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turma.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${turma.horarioInicio} · ${turma.duracaoMinutos} min',
                        style:
                            TextStyle(fontSize: 14, color: cores.textoSuave),
                      ),
                      if (s.nomeProfessora != null)
                        Text(
                          s.nomeProfessora!,
                          style: TextStyle(
                              fontSize: 13, color: cores.textoFraco),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      s.textoOcupacao,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'bikes',
                      style:
                          TextStyle(fontSize: 11, color: cores.textoFraco),
                    ),
                    if (s.bikesEmManutencao > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${s.bikesEmManutencao} em manut.',
                          style: TextStyle(
                              fontSize: 12, color: cores.textoFraco),
                        ),
                      ),
                    if ((s.totalNaFila ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${s.totalNaFila} na fila',
                          style: TextStyle(
                            fontSize: 13,
                            color: cores.alerta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14, 0, 14,
              s.status == StatusCheckinAluno.emFila ? 6 : 14,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: s.botaoAtivo ? widget.onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _corBotao(s.status),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      _corBotaoDesabilitado(s.status),
                  disabledForegroundColor:
                      _corTextoBotaoDesabilitado(s.status, cores),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(s.labelBotao),
              ),
            ),
          ),
          if (s.status == StatusCheckinAluno.emFila)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: widget.onSairFila,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CoresApp.alerta,
                    side: BorderSide(color: CoresApp.alerta),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Sair da Fila'),
                ),
              ),
            ),
          if (mix != null)
            PainelMix(
              mix: mix,
              onAvaliar: (musicaId, nota) =>
                  _controlador.avaliarMusica(widget.alunoId, musicaId, nota),
            ),
          if ((s.totalNaFila ?? 0) > 0)
            _BotaoFilaEspera(
              total: s.totalNaFila!,
              onTap: () => _mostrarFilaModal(context),
            ),
        ],
      ),
    );
  }

  Color _corBotao(StatusCheckinAluno status) => switch (status) {
        StatusCheckinAluno.disponivel => CoresApp.sucesso,
        StatusCheckinAluno.lotada => CoresApp.alerta,
        StatusCheckinAluno.confirmado => CoresApp.erro,
        _ => CoresApp.superficieSuave,
      };

  Color _corBotaoDesabilitado(StatusCheckinAluno status) =>
      CoresApp.superficieSuave;

  Color _corTextoBotaoDesabilitado(
          StatusCheckinAluno status, CoresSemanticasApp cores) =>
      cores.textoFraco;
}

// ── Cartão de nível do aluno (gradiente + timeline) ──────────────────────────

class _CartaoNivel extends StatelessWidget {
  final int semanasSeguidas;

  const _CartaoNivel({required this.semanasSeguidas});

  NivelAluno get _nivel => NivelAluno.fromSemanasSeguidas(semanasSeguidas);

  int get _indiceAtual {
    switch (_nivel) {
      case NivelAluno.diamante:
        return 2;
      case NivelAluno.ouro:
        return 1;
      case NivelAluno.prata:
        return 0;
      case NivelAluno.nenhum:
        return -1;
    }
  }

  List<Color> _gradiente(NivelAluno nivel) {
    switch (nivel) {
      case NivelAluno.prata:
        return const [Color(0xFFCBD2D9), Color(0xFF9AA3AD)];
      case NivelAluno.ouro:
        return const [Color(0xFFF6CB49), Color(0xFFCB9214)];
      case NivelAluno.diamante:
        return const [Color(0xFF7FD0F5), Color(0xFF2B73C4)];
      case NivelAluno.nenhum:
        return const [Color(0xFF6B7280), Color(0xFF4B5563)];
    }
  }

  /// Cor sólida de cada nível (usada nos ícones da timeline).
  Color _corNivel(NivelAluno nivel) {
    switch (nivel) {
      case NivelAluno.prata:
        return const Color(0xFF8A929C);
      case NivelAluno.ouro:
        return const Color(0xFFC9971B);
      case NivelAluno.diamante:
        return const Color(0xFF2B73C4);
      case NivelAluno.nenhum:
        return const Color(0xFF6B7280);
    }
  }

  IconData _iconeNivel(NivelAluno nivel) {
    switch (nivel) {
      case NivelAluno.prata:
        return Icons.workspace_premium;
      case NivelAluno.ouro:
        return Icons.military_tech;
      case NivelAluno.diamante:
        return Icons.diamond;
      case NivelAluno.nenhum:
        return Icons.lock_outline;
    }
  }

  /// Cor do texto sobre o gradiente — escura nos níveis claros (prata/ouro).
  Color get _corTexto =>
      (_nivel == NivelAluno.prata || _nivel == NivelAluno.ouro)
          ? const Color(0xFF2A2A2A)
          : Colors.white;

  String get _subtitulo {
    if (semanasSeguidas <= 0) return 'Comece uma sequência semanal';
    final s = semanasSeguidas == 1
        ? '1 semana seguida'
        : '$semanasSeguidas semanas seguidas';
    // Progresso até o próximo nível.
    final proximo = _proximoNivel();
    if (proximo == null) return '$s · nível máximo';
    final faltam = proximo.semanasMinimas - semanasSeguidas;
    final txtFaltam = faltam == 1 ? '1 semana' : '$faltam semanas';
    return '$s · faltam $txtFaltam para ${proximo.rotulo}';
  }

  NivelAluno? _proximoNivel() {
    switch (_nivel) {
      case NivelAluno.nenhum:
        return NivelAluno.prata;
      case NivelAluno.prata:
        return NivelAluno.ouro;
      case NivelAluno.ouro:
        return NivelAluno.diamante;
      case NivelAluno.diamante:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final corTexto = _corTexto;
    final tituloNivel =
        _nivel == NivelAluno.nenhum ? 'Iniciante' : 'Nível ${_nivel.rotulo}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradiente(_nivel),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _gradiente(_nivel).last.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconeNivel(_nivel), color: corTexto, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tituloNivel,
                      style: TextStyle(
                        color: corTexto,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitulo,
                      style: TextStyle(
                        color: corTexto.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildTimeline(corTexto),
        ],
      ),
    );
  }

  Widget _buildTimeline(Color corTexto) {
    final niveis = NivelAluno.niveisTimeline;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ponto(niveis[0], 0),
            _conector(ativo: _indiceAtual >= 1),
            _ponto(niveis[1], 1),
            _conector(ativo: _indiceAtual >= 2),
            _ponto(niveis[2], 2),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _rotuloPonto(niveis[0], 0, corTexto, TextAlign.left)),
            Expanded(
                child: _rotuloPonto(niveis[1], 1, corTexto, TextAlign.center)),
            Expanded(
                child: _rotuloPonto(niveis[2], 2, corTexto, TextAlign.right)),
          ],
        ),
      ],
    );
  }

  Widget _conector({required bool ativo}) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: ativo ? Colors.white : Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _ponto(NivelAluno nivel, int indice) {
    final alcancado = indice <= _indiceAtual;
    final atual = indice == _indiceAtual;
    final corIcone = alcancado ? _corNivel(nivel) : Colors.white;
    // Preenchimento em tom bem suave da cor do nível quando alcançado.
    final corPreenchimento = alcancado
        ? Color.lerp(_corNivel(nivel), Colors.white, 0.85)!
        : Colors.white.withValues(alpha: 0.25);

    return Container(
      width: atual ? 44 : 38,
      height: atual ? 44 : 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: corPreenchimento,
        border: atual ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: atual
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        _iconeNivel(nivel),
        size: atual ? 24 : 20,
        color: alcancado ? corIcone : Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _rotuloPonto(
      NivelAluno nivel, int indice, Color corTexto, TextAlign alinhamento) {
    final atual = indice == _indiceAtual;
    return Text(
      nivel.rotulo,
      textAlign: alinhamento,
      style: TextStyle(
        color: corTexto.withValues(alpha: atual ? 1 : 0.75),
        fontSize: 13,
        fontWeight: atual ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}

// ── Botão fila de espera no card do aluno ────────────────────────────────────

class _BotaoFilaEspera extends StatelessWidget {
  final int total;
  final VoidCallback onTap;

  const _BotaoFilaEspera({required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    return Column(
      children: [
        const Divider(height: 1),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 18, color: cores.alerta),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fila de espera · $total '
                    '${total == 1 ? 'pessoa' : 'pessoas'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cores.alerta,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: cores.textoSuave),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
