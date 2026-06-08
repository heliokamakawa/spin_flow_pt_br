import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_checkin_aluno.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/mix_checkin.dart';
import 'package:spin_flow/domain/modelo/musica_checkin.dart';
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
              style: TextStyle(color: cores.textoFraco, fontSize: 13),
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
              style: TextStyle(color: cores.textoFraco, fontSize: 13),
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
                    fontSize: 13,
                  ),
                ),
                if (m.nomeArtista.isNotEmpty)
                  Text(
                    m.nomeArtista,
                    style: TextStyle(fontSize: 11, color: cores.textoFraco),
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
          style: TextStyle(color: cores.textoFraco, fontSize: 13),
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
          style: TextStyle(color: cores.textoFraco, fontSize: 13),
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
                    fontSize: 13,
                  ),
                ),
                if (m.nomeArtista.isNotEmpty)
                  Text(
                    m.nomeArtista,
                    style: TextStyle(fontSize: 11, color: cores.textoFraco),
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
                    fontSize: 13,
                  ),
                ),
                if (m.nomeArtista.isNotEmpty)
                  Text(
                    m.nomeArtista,
                    style: TextStyle(fontSize: 11, color: cores.textoFraco),
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
        Text(label, style: TextStyle(fontSize: 12, color: cores.textoSuave)),
      ],
    );
  }

  Widget _divisorVertical() =>
      const SizedBox(height: 40, child: VerticalDivider());

}

// ── Card Check-in ─────────────────────────────────────────────────────────────

class _CardCheckin extends StatefulWidget {
  final SituacaoCheckinAluno situacao;
  final int alunoId;
  final VoidCallback onTap;

  const _CardCheckin({
    required this.situacao,
    required this.alunoId,
    required this.onTap,
  });

  @override
  State<_CardCheckin> createState() => _CardCheckinState();
}

class _CardCheckinState extends State<_CardCheckin> {
  final _controlador = ControladorCheckinAluno();

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
                            TextStyle(fontSize: 13, color: cores.textoSuave),
                      ),
                      if (s.nomeProfessora != null)
                        Text(
                          s.nomeProfessora!,
                          style: TextStyle(
                              fontSize: 12, color: cores.textoFraco),
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
                              fontSize: 11, color: cores.textoFraco),
                        ),
                      ),
                    if ((s.totalNaFila ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${s.totalNaFila} na fila',
                          style: TextStyle(
                            fontSize: 12,
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
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
          if (mix != null)
            PainelMix(
              mix: mix,
              onAvaliar: (musicaId, nota) =>
                  _controlador.avaliarMusica(widget.alunoId, musicaId, nota),
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
