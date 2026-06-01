import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_aluno.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_avaliacao_musica.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_checkin.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_turma.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_turma_mix.dart';
import 'package:spin_flow/excluir/configuracoes/rotas.dart';
import 'package:spin_flow/excluir/configuracoes/sessao_usuario.dart';
import 'package:spin_flow/excluir/dto/dto_aluno.dart';
import 'package:spin_flow/excluir/dto/dto_checkin.dart';
import 'package:spin_flow/excluir/dto/dto_musica.dart';
import 'package:spin_flow/excluir/dto/dto_turma.dart';
import 'package:spin_flow/excluir/dto/dto_turma_mix.dart';
import 'package:spin_flow/excluir/widget/aluno/tela_checkin_aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class TelaDashboardAluno extends StatefulWidget {
  const TelaDashboardAluno({super.key});

  @override
  State<TelaDashboardAluno> createState() => _TelaDashboardAlunoState();
}

class _TelaDashboardAlunoState extends State<TelaDashboardAluno> {
  final DAOAluno _daoAluno = DAOAluno();
  final DAOCheckin _daoCheckin = DAOCheckin();
  final DAOTurma _daoTurma = DAOTurma();
  final DAOTurmaMix _daoTurmaMix = DAOTurmaMix();
  final DAOAvaliacaoMusica _daoAvaliacaoMusica = DAOAvaliacaoMusica();
  final TextEditingController _buscaCheckinController = TextEditingController();

  bool _carregando = true;
  DTOAluno? _alunoLogado;
  int _aulasHoje = 0;
  int _agendadas = 0;
  int _concluidasMes = 0;
  int _totalAulas3Meses = 0;
  int _checkinsHoje = 0;
  String _proximaAula = '-';
  String _ultimaAula = '-';
  String _termoBuscaCheckin = '';
  List<_CheckinComMix> _checkinsComMix = [];
  final Map<String, int> _avaliacoesMusicas = {};

  @override
  void initState() {
    super.initState();
    _buscaCheckinController.addListener(() {
      setState(() {
        _termoBuscaCheckin = _buscaCheckinController.text.trim().toLowerCase();
      });
    });
    _carregarResumo();
  }

  @override
  void dispose() {
    _buscaCheckinController.dispose();
    super.dispose();
  }

  Future<void> _carregarResumo() async {
    setState(() => _carregando = true);
    final email = SessaoUsuario.email;
    final aluno = email == null
        ? null
        : await _daoAluno.buscarPorEmailAtivo(email);

    final hoje = DateTime.now();
    final hojeData = DateTime(hoje.year, hoje.month, hoje.day);

    int agendadas = 0;
    int concluidasMes = 0;
    int totalAulas3Meses = 0;
    int checkinsHoje = 0;
    String proximaAula = '-';
    String ultimaAula = '-';
    List<_CheckinComMix> checkinsComMix = [];
    final avaliacoesMusicas = <String, int>{};

    if (aluno != null) {
      final checkins = await _daoCheckin.buscarPorAluno(aluno.id ?? 0);
      final ativos = checkins.where((c) => c.ativo).toList();
      ativos.sort((a, b) => b.data.compareTo(a.data));

      agendadas = ativos.where((c) {
        final d = DateTime(c.data.year, c.data.month, c.data.day);
        return d.isAtSameMomentAs(hojeData) || d.isAfter(hojeData);
      }).length;

      final limite30Dias = hojeData.subtract(const Duration(days: 30));
      concluidasMes = ativos.where((c) {
        final d = DateTime(c.data.year, c.data.month, c.data.day);
        return d.isBefore(hojeData) && d.isAfter(limite30Dias);
      }).length;

      checkinsHoje = ativos.where((c) {
        final d = DateTime(c.data.year, c.data.month, c.data.day);
        return d.isAtSameMomentAs(hojeData);
      }).length;

      final limite3Meses = DateTime(hoje.year, hoje.month - 3, hoje.day);
      final passados = ativos.where((c) {
        final d = DateTime(c.data.year, c.data.month, c.data.day);
        return d.isBefore(hojeData) && d.isAfter(limite3Meses);
      }).toList();

      totalAulas3Meses = passados.length;
      if (passados.isNotEmpty) {
        passados.sort((a, b) => b.data.compareTo(a.data));
        final ultima = passados.first;
        ultimaAula =
            '${ultima.turma.nome} - ${_formatarDataCurta(ultima.data)}';
      }

      checkinsComMix = await _carregarCheckinsComMix(ativos);
      avaliacoesMusicas.addAll(
        await _carregarAvaliacoesMusicas(aluno, checkinsComMix),
      );
    }

    final turmas = await _daoTurma.buscarAtivas();
    final turmasHoje = turmas.where((t) => _diaCompativel(t, hojeData)).toList()
      ..sort((a, b) => a.horarioInicio.compareTo(b.horarioInicio));

    for (final turma in turmasHoje) {
      final inicio = _inicioAula(turma, hojeData);
      if (inicio.isAfter(hoje)) {
        proximaAula = '${turma.nome} - ${turma.horarioInicio}';
        break;
      }
    }

    if (!mounted) return;
    setState(() {
      _alunoLogado = aluno;
      _aulasHoje = turmasHoje.length;
      _agendadas = agendadas;
      _concluidasMes = concluidasMes;
      _totalAulas3Meses = totalAulas3Meses;
      _checkinsHoje = checkinsHoje;
      _proximaAula = proximaAula;
      _ultimaAula = ultimaAula;
      _checkinsComMix = checkinsComMix;
      _avaliacoesMusicas
        ..clear()
        ..addAll(avaliacoesMusicas);
      _carregando = false;
    });
  }

  Future<List<_CheckinComMix>> _carregarCheckinsComMix(
    List<DTOCheckin> checkins,
  ) async {
    final itens = <_CheckinComMix>[];
    for (final checkin in checkins) {
      final turmaId = checkin.turma.id;
      if (turmaId == null) continue;
      final mix =
          await _daoTurmaMix.buscarAtivoPorTurma(turmaId, data: checkin.data) ??
          await _daoTurmaMix.buscarAtivoPorTurma(turmaId);
      itens.add(_CheckinComMix(checkin: checkin, mix: mix));
    }
    return itens;
  }

  Future<Map<String, int>> _carregarAvaliacoesMusicas(
    DTOAluno aluno,
    List<_CheckinComMix> itens,
  ) async {
    final alunoId = aluno.id;
    if (alunoId == null) return {};

    final musicas = itens
        .expand((item) => item.mix?.mix.musicas ?? const <DTOMusica>[])
        .toList();
    final musicaIds = musicas
        .map((m) => m.id)
        .whereType<int>()
        .toSet()
        .toList();
    final avaliacoes = await _daoAvaliacaoMusica.buscarPorAlunoEMusicas(
      alunoId: alunoId,
      musicaIds: musicaIds,
    );

    return {
      for (var i = 0; i < musicas.length; i++)
        if (musicas[i].id != null)
          _chaveAvaliacaoMusica(musicas[i], i): avaliacoes[musicas[i].id] ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const TituloAppBarSpinFlow(contexto: 'Aluno'),
              centerTitle: true,
              actions: const [AcaoSairAppBar()],
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.pin_drop), text: 'Check-in'),
                  Tab(icon: Icon(Icons.dashboard), text: 'Meu Painel'),
                ],
              ),
            ),
            drawer: _buildDrawer(context),
            body: TabBarView(
              children: [
                const TelaCheckinAluno(exibirAppBar: false),
                _buildMeuPainel(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: CoresApp.barraApp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  SessaoUsuario.nome ?? 'Aluno',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  SessaoUsuario.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pin_drop),
            title: const Text('Check-in'),
            onTap: () {
              Navigator.pop(context);
              DefaultTabController.of(context).animateTo(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Meu Painel'),
            onTap: () {
              Navigator.pop(context);
              DefaultTabController.of(context).animateTo(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Rotas.historicoAluno);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Rotas.perfil);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              SessaoUsuario.encerrar();
              Navigator.pushReplacementNamed(context, Rotas.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeuPainel() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _carregarResumo,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar painel'),
          ),
        ),
        const SizedBox(height: 4),
        _cardReservaDestaque(context),
        const SizedBox(height: 16),
        _buildAcoesPrincipais(context),
        const SizedBox(height: 20),
        const Text(
          'Resumo geral',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _resumoGrandeCard(
                'Aulas realizadas',
                '$_concluidasMes',
                'Últimos 30 dias',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _resumoGrandeCard(
                'Reservas ativas',
                '$_agendadas',
                'Hoje em diante',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Indicadores',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildIndicadoresGrid(),
        const SizedBox(height: 16),
        _buildBuscaCheckinsAvaliacao(),
      ],
    );
  }

  Widget _cardReservaDestaque(BuildContext context) {
    final subtitulo = _proximaAula == '-'
        ? 'Veja as turmas de hoje e escolha sua bike no mapa.'
        : 'Próxima aula: $_proximaAula';

    return Card(
      color: CoresApp.primariaSuave,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reservas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtitulo),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => DefaultTabController.of(context).animateTo(0),
                icon: const Icon(Icons.pin_drop),
                label: const Text('Fazer reserva agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcoesPrincipais(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _botaoAcessoPainel(
            context: context,
            titulo: 'Histórico de aulas',
            icone: Icons.history,
            rota: Rotas.historicoAluno,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _botaoAcessoPainel(
            context: context,
            titulo: 'Agenda completa',
            icone: Icons.calendar_month,
            rota: Rotas.agendaAluno,
          ),
        ),
      ],
    );
  }

  Widget _botaoAcessoPainel({
    required BuildContext context,
    required String titulo,
    required IconData icone,
    required String rota,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(context, rota),
        icon: Icon(icone, size: 20),
        label: Text(
          titulo,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBuscaCheckinsAvaliacao() {
    final item = _checkinSelecionadoParaAvaliacao();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avaliar músicas por check-in',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _buscaCheckinController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _termoBuscaCheckin.isEmpty
                ? null
                : IconButton(
                    onPressed: _buscaCheckinController.clear,
                    icon: const Icon(Icons.close),
                  ),
            labelText: 'Buscar check-in',
            hintText: 'Atualizar por turma, data ou mix',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        if (_checkinsComMix.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.music_off),
              title: Text('Nenhum check-in ativo encontrado.'),
            ),
          )
        else if (item == null)
          const Card(
            child: ListTile(
              leading: Icon(Icons.search_off),
              title: Text('Nenhum check-in encontrado para a busca.'),
            ),
          )
        else
          _buildCheckinAvaliacaoTile(item),
      ],
    );
  }

  _CheckinComMix? _checkinSelecionadoParaAvaliacao() {
    final candidatos = _termoBuscaCheckin.isEmpty
        ? _checkinsParticipados()
        : _checkinsComMix.where((item) {
            final checkin = item.checkin;
            final mix = item.mix?.mix;
            final alvo = [
              checkin.turma.nome,
              _formatarDataCurta(checkin.data),
              checkin.turma.horarioInicio,
              mix?.nome ?? '',
            ].join(' ').toLowerCase();
            return alvo.contains(_termoBuscaCheckin);
          }).toList();

    if (candidatos.isNotEmpty) return candidatos.first;
    if (_termoBuscaCheckin.isEmpty && _checkinsComMix.isNotEmpty) {
      return _checkinsComMix.first;
    }
    return null;
  }

  List<_CheckinComMix> _checkinsParticipados() {
    final hoje = DateTime.now();
    final hojeData = DateTime(hoje.year, hoje.month, hoje.day);
    return _checkinsComMix.where((item) {
      final checkin = item.checkin;
      final data = DateTime(
        checkin.data.year,
        checkin.data.month,
        checkin.data.day,
      );
      return data.isBefore(hojeData) || data.isAtSameMomentAs(hojeData);
    }).toList();
  }

  Widget _buildCheckinAvaliacaoTile(_CheckinComMix item) {
    final checkin = item.checkin;
    final mix = item.mix;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.library_music),
        title: Text(mix?.mix.nome ?? 'Mix da aula'),
        subtitle: Text(
          '${checkin.turma.nome} - ${_formatarDataCurta(checkin.data)}'
          '${mix == null ? ' - sem musicas' : ' - ${mix.mix.musicas.length} musicas'}',
        ),
        trailing: TextButton.icon(
          onPressed: () => _abrirModalAvaliacaoCheckin(item),
          icon: const Icon(Icons.star_border, size: 18),
          label: const Text('Avaliar'),
        ),
        onTap: () => _abrirModalAvaliacaoCheckin(item),
      ),
    );
  }

  void _abrirModalAvaliacaoCheckin(_CheckinComMix item) {
    final checkin = item.checkin;
    final mix = item.mix;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, atualizarModal) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.78,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mix?.mix.nome ?? 'Mix da aula',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${checkin.turma.nome} - ${_formatarDataCurta(checkin.data)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (mix == null)
                        const Text(
                          'Nao ha musicas para avaliar neste check-in.',
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: mix.mix.musicas.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (_, index) {
                              final musica = mix.mix.musicas[index];
                              return _buildMusicaAvaliacao(
                                musica: musica,
                                indice: index,
                                atualizarModal: atualizarModal,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMusicaAvaliacao({
    required DTOMusica musica,
    required int indice,
    StateSetter? atualizarModal,
  }) {
    final chave = _chaveAvaliacaoMusica(musica, indice);
    final avaliacao = _avaliacoesMusicas[chave] ?? 0;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '${musica.nome} (${musica.artista.nome})',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final valor = index + 1;
              final marcada = valor <= avaliacao;
              return IconButton(
                onPressed: () {
                  _registrarAvaliacaoMusica(
                    musica: musica,
                    indice: indice,
                    nota: valor,
                  );
                  atualizarModal?.call(() {});
                },
                icon: Icon(marcada ? Icons.star : Icons.star_border),
                color: CoresApp.energia,
                tooltip: '$valor estrela${valor == 1 ? '' : 's'}',
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 36,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              );
            }),
          ),
        ],
      ),
    );
  }

  String _chaveAvaliacaoMusica(DTOMusica musica, int indice) {
    final id = musica.id;
    if (id != null) return 'id:$id';
    return 'indice:$indice:${musica.nome}';
  }

  Future<void> _registrarAvaliacaoMusica({
    required DTOMusica musica,
    required int indice,
    required int nota,
  }) async {
    final chave = _chaveAvaliacaoMusica(musica, indice);
    setState(() => _avaliacoesMusicas[chave] = nota);

    final alunoId = _alunoLogado?.id;
    final musicaId = musica.id;
    if (alunoId == null || musicaId == null) return;

    try {
      await _daoAvaliacaoMusica.salvar(
        alunoId: alunoId,
        musicaId: musicaId,
        nota: nota,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar avaliacao da musica: $e')),
      );
    }
  }

  Widget _resumoGrandeCard(String titulo, String valor, String subtitulo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadoresGrid() {
    final indicadores = [
      _IndicadorPainel(
        icone: Icons.fitness_center,
        titulo: 'Aulas registradas',
        subtitulo: 'Ultimos 3 meses',
        valor: '$_totalAulas3Meses',
      ),
      _IndicadorPainel(
        icone: Icons.today,
        titulo: 'Turmas hoje',
        subtitulo: 'Agenda',
        valor: '$_aulasHoje',
      ),
      _IndicadorPainel(
        icone: Icons.event_available,
        titulo: 'Check-ins hoje',
        subtitulo: 'Reservas ativas',
        valor: '$_checkinsHoje',
      ),
      _IndicadorPainel(
        icone: Icons.history,
        titulo: 'Ultima aula',
        subtitulo: 'Registro ativo',
        valor: _ultimaAula,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: indicadores.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.72,
      ),
      itemBuilder: (context, index) {
        final item = indicadores[index];
        return _indicadorCard(
          item.icone,
          item.titulo,
          item.subtitulo,
          item.valor,
        );
      },
    );
  }

  Widget _indicadorCard(
    IconData icone,
    String titulo,
    String subtitulo,
    String valor,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CoresApp.superficieElevada,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CoresApp.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: CoresApp.primariaSuave,
                child: Icon(icone, size: 16, color: CoresApp.primaria),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  bool _diaCompativel(DTOTurma turma, DateTime data) {
    final dia = _nomeDia(data);
    if (turma.diasSemana.contains(dia)) return true;
    if (dia == 'Sab' && turma.diasSemana.contains('Sab')) return true;
    return false;
  }

  String _nomeDia(DateTime data) {
    switch (data.weekday) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sab';
      default:
        return 'Dom';
    }
  }

  DateTime _inicioAula(DTOTurma turma, DateTime dataAula) {
    final partes = turma.horarioInicio.split(':');
    final h = partes.isNotEmpty ? int.tryParse(partes[0]) ?? 0 : 0;
    final m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return DateTime(dataAula.year, dataAula.month, dataAula.day, h, m);
  }

  String _formatarDataCurta(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }
}

class _CheckinComMix {
  final DTOCheckin checkin;
  final DTOTurmaMix? mix;

  const _CheckinComMix({required this.checkin, required this.mix});
}

class _IndicadorPainel {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final String valor;

  const _IndicadorPainel({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
  });
}
