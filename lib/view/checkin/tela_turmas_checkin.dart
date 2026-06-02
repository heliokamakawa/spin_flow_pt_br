import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/controlador_checkin_aluno.dart';
import 'package:spin_flow/infra/autenticacao/sessao_usuario.dart';
import 'package:spin_flow/infra/tema/cores_app.dart';
import 'package:spin_flow/infra/tema/tema_app.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/painel_mix.dart';
import '../../domain/modelo/situacao_checkin_aluno.dart';
import 'package:spin_flow/view/checkin/tela_mapa_checkin_aluno.dart';

class TelaTurmasCheckin extends StatefulWidget {
  const TelaTurmasCheckin({super.key});

  @override
  State<TelaTurmasCheckin> createState() => _TelaTurmasCheckinState();
}

class _TelaTurmasCheckinState extends State<TelaTurmasCheckin> {
  final _controlador = GetIt.I<ControladorCheckinAluno>();

  int? _alunoId;
  List<SituacaoCheckinAluno> _situacoes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final alunoId = SessaoUsuario.alunoId;
    if (alunoId == null) {
      setState(() {
        _erro = 'Sessão expirada.';
        _carregando = false;
      });
      return;
    }
    _alunoId = alunoId;
    await _carregar();
  }

  Future<void> _carregar() async {
    final alunoId = _alunoId;
    if (alunoId == null) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _controlador.listarTurmasHoje(alunoId);
      if (!mounted) return;
      setState(() {
        _situacoes = lista;
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
              builder: (_) => TelaMapeamentoCheckinAluno(
                turmaId: s.turma.id!,
                alunoId: _alunoId!,
              ),
            ))
            .then((_) => _carregar());
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
      await _carregar();
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
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!, textAlign: TextAlign.center),
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
            Text(
              'Nenhuma aula hoje.',
              style: TextStyle(color: cores.textoSuave),
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
        itemCount: _situacoes.length,
        itemBuilder: (_, i) => _CardCheckin(
          situacao: _situacoes[i],
          alunoId: _alunoId!,
          onTap: () => _aoTocarCard(_situacoes[i]),
        ),
      ),
    );
  }
}

// -- Card --------------------------------------------------------------------

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
  final _controlador = GetIt.I<ControladorCheckinAluno>();

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
                // Coluna 1 — nome, horário, professora
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
                        style: TextStyle(fontSize: 13, color: cores.textoSuave),
                      ),
                      if (s.nomeProfessora != null)
                        Text(
                          s.nomeProfessora!,
                          style: TextStyle(fontSize: 12, color: cores.textoFraco),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Coluna 2 — ocupação e fila
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
                      style: TextStyle(fontSize: 11, color: cores.textoFraco),
                    ),
                    if (s.bikesEmManutencao > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${s.bikesEmManutencao} em manut.',
                          style: TextStyle(
                            fontSize: 11,
                            color: cores.textoFraco,
                          ),
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
                  disabledBackgroundColor: _corBotaoDesabilitado(s.status),
                  disabledForegroundColor: _corTextoBotaoDesabilitado(s.status, cores),
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
    StatusCheckinAluno.disponivel  => CoresApp.sucesso,
    StatusCheckinAluno.lotada      => CoresApp.alerta,
    StatusCheckinAluno.confirmado  => CoresApp.erro,
    _                              => CoresApp.superficieSuave,
  };

  // Conflito e demais inativos: cinza neutro
  Color _corBotaoDesabilitado(StatusCheckinAluno status) =>
      CoresApp.superficieSuave;

  Color _corTextoBotaoDesabilitado(
          StatusCheckinAluno status, CoresSemanticasApp cores) =>
      cores.textoFraco;
}
