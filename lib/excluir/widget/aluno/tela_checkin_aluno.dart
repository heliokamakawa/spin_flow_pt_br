import 'package:flutter/material.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_aluno.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_checkin.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_fila_espera_checkin.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_manutencao.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_posicao_bike.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_turma.dart';
import 'package:spin_flow/excluir/configuracoes/rotas.dart';
import 'package:spin_flow/excluir/configuracoes/sessao_usuario.dart';
import 'package:spin_flow/excluir/dto/dto_aluno.dart';
import 'package:spin_flow/excluir/dto/dto_checkin.dart';
import 'package:spin_flow/excluir/dto/dto_posicao_bike.dart';
import 'package:spin_flow/excluir/dto/dto_turma.dart';
import 'package:spin_flow/core/tema/tema_app.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class TelaCheckinAluno extends StatefulWidget {
  final bool exibirAppBar;

  const TelaCheckinAluno({super.key, this.exibirAppBar = true});

  @override
  State<TelaCheckinAluno> createState() => _TelaCheckinAlunoState();
}

class _TelaCheckinAlunoState extends State<TelaCheckinAluno> {
  final DAOAluno _daoAluno = DAOAluno();
  final DAOTurma _daoTurma = DAOTurma();
  final DAOCheckin _daoCheckin = DAOCheckin();
  final DAOManutencao _daoManutencao = DAOManutencao();
  final DAOPosicaoBike _daoPosicaoBike = DAOPosicaoBike();
  final DAOFilaEsperaCheckin _daoFilaEspera = DAOFilaEsperaCheckin();

  bool _carregando = true;
  final DateTime _hoje = DateTime.now();
  List<_ResumoTurmaHoje> _resumos = [];
  String? _erroCarregamento;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroCarregamento = null;
    });
    try {
      final aluno = await _buscarAlunoLogado();
      final checkinsAluno = aluno?.id == null
          ? <DTOCheckin>[]
          : (await _daoCheckin.buscarPorAluno(
              aluno!.id!,
            )).where((c) => c.ativo && _mesmaData(c.data, _hoje)).toList();
      final turmas = await _daoTurma.buscarAtivas();
      final bikesBloqueadas = await _daoManutencao
          .buscarBikeIdsEmManutencaoAtiva();
      final posicoesBloqueadas = await _daoPosicaoBike.buscarPorBikeIds(
        bikesBloqueadas,
      );
      final posicoesTodas = await _daoPosicaoBike.buscarTodos();

      final List<_ResumoTurmaHoje> lista = [];
      for (final t in turmas) {
        if (!_diaCompativel(t, _hoje)) continue;

        final checkins = await _daoCheckin.buscarAtivosPorTurmaData(
          turmaId: t.id ?? 0,
          data: _hoje,
        );
        final meuCheckin = aluno == null
            ? null
            : _buscarMeuCheckin(checkins: checkins, aluno: aluno);
        final checkinConflitante = meuCheckin != null
            ? null
            : _buscarCheckinConflitante(
                checkinsAluno: checkinsAluno,
                turma: t,
                data: _hoje,
              );
        final fila = await _daoFilaEspera.buscarAtivosPorTurmaData(
          turmaId: t.id ?? 0,
          data: _hoje,
        );

        final posicionadas = posicoesTodas
            .where((p) => _estaNaGrade(p, t))
            .toList();
        final bloqueadas = posicoesBloqueadas
            .where((p) => _estaNaGrade(p, t))
            .toList();

        final reservaveis = posicionadas
            .where((p) => !_ehProfessora(t, p) && !_contido(bloqueadas, p))
            .length;
        if (reservaveis <= 0) {
          continue;
        }
        final vagas = (reservaveis - checkins.length).clamp(0, reservaveis);

        lista.add(
          _ResumoTurmaHoje(
            turma: t,
            reservaveis: reservaveis,
            vagas: vagas,
            filaEspera: fila.length,
            checkinsAtivos: checkins.length,
            meuCheckin: meuCheckin,
            checkinConflitante: checkinConflitante,
            podeReservarAgora: _podeReservarAgora(t),
          ),
        );
      }

      lista.sort(
        (a, b) => a.turma.horarioInicio.compareTo(b.turma.horarioInicio),
      );

      if (!mounted) return;
      setState(() {
        _resumos = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroCarregamento = 'Erro ao carregar turmas para check-in: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.exibirAppBar
          ? AppBar(
              title: const TituloAppBarSpinFlow(),
              actions: const [AcaoSairAppBar()],
            )
          : null,
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erroCarregamento != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_erroCarregamento!, textAlign: TextAlign.center),
              ),
            )
          : _resumos.isEmpty
          ? const Center(child: Text('Não há turmas disponíveis hoje.'))
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _resumos.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _carregar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Atualizar aulas'),
                      ),
                    );
                  }

                  final resumo = _resumos[index - 1];
                  return _CardTurmaCheckin(
                    resumo: resumo,
                    aoAgir: () => _aoTocarTurma(resumo),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _aoTocarTurma(_ResumoTurmaHoje resumo) async {
    if (resumo.meuCheckin != null) {
      await _confirmarCancelamento(resumo);
      return;
    }

    if (!resumo.podeReservarAgora) {
      final inicio = _inicioAula(resumo.turma, _hoje);
      final limite = inicio.subtract(const Duration(minutes: 30));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reserva bloqueada. Liberada a partir das ${_formatarHora(limite)}.',
          ),
        ),
      );
      return;
    }

    if (resumo.checkinConflitante != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Você já possui check-in em ${resumo.checkinConflitante!.turma.nome} neste horário.',
          ),
        ),
      );
      return;
    }

    if (resumo.vagas == 0) {
      await _mostrarDialogoTurmaLotada(resumo);
      return;
    }

    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      Rotas.mapaCheckin,
      arguments: {
        'turma': resumo.turma,
        'data': DateTime(_hoje.year, _hoje.month, _hoje.day),
      },
    );
    await _carregar();
  }

  Future<void> _confirmarCancelamento(_ResumoTurmaHoje resumo) async {
    final checkin = resumo.meuCheckin;
    if (checkin?.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar check-in'),
        content: Text('Deseja cancelar seu check-in em ${resumo.turma.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).extension<CoresSemanticasApp>()!.erroForte,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancelar check-in'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await _daoCheckin.cancelar(checkin!.id!);
    await _carregar();
  }

  Future<void> _mostrarDialogoTurmaLotada(_ResumoTurmaHoje resumo) async {
    final entrarNaFila = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Turma lotada'),
        content: Text(
          'A turma ${resumo.turma.nome} está sem vagas no momento. Deseja entrar na fila de espera?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Entrar na fila'),
          ),
        ],
      ),
    );

    if (entrarNaFila == true) {
      await _entrarFilaDeEspera(resumo);
    }
  }

  Future<void> _entrarFilaDeEspera(_ResumoTurmaHoje resumo) async {
    try {
      final aluno = await _buscarAlunoLogado();
      if (aluno?.id == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aluno logado não encontrado para entrar na fila de espera.',
            ),
          ),
        );
        return;
      }

      final jaTemCheckin = await _daoCheckin.existeCheckinAtivoAluno(
        alunoId: aluno!.id!,
        turmaId: resumo.turma.id ?? 0,
        data: _hoje,
      );
      if (jaTemCheckin) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você já possui check-in ativo para esta turma.'),
          ),
        );
        return;
      }

      await _daoFilaEspera.entrarNaFila(
        alunoId: aluno.id!,
        turmaId: resumo.turma.id ?? 0,
        data: _hoje,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você entrou na fila de espera da turma.'),
        ),
      );
      await _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<DTOAluno?> _buscarAlunoLogado() async {
    final email = SessaoUsuario.email;
    if (email == null || email.trim().isEmpty) return null;
    return _daoAluno.buscarPorEmailAtivo(email);
  }

  DTOCheckin? _buscarMeuCheckin({
    required List<DTOCheckin> checkins,
    required DTOAluno aluno,
  }) {
    for (final checkin in checkins) {
      if (checkin.aluno.id == aluno.id) return checkin;
    }
    return null;
  }

  DTOCheckin? _buscarCheckinConflitante({
    required List<DTOCheckin> checkinsAluno,
    required DTOTurma turma,
    required DateTime data,
  }) {
    for (final checkin in checkinsAluno) {
      if (checkin.turma.id == turma.id) continue;
      if (_horariosSobrepostos(checkin.turma, turma, data)) {
        return checkin;
      }
    }
    return null;
  }

  bool _horariosSobrepostos(DTOTurma turmaA, DTOTurma turmaB, DateTime data) {
    final inicioA = _inicioAula(turmaA, data);
    final fimA = inicioA.add(Duration(minutes: turmaA.duracaoMinutos));
    final inicioB = _inicioAula(turmaB, data);
    final fimB = inicioB.add(Duration(minutes: turmaB.duracaoMinutos));
    return inicioA.isBefore(fimB) && inicioB.isBefore(fimA);
  }

  bool _mesmaData(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _diaCompativel(DTOTurma turma, DateTime data) {
    final dia = _nomeDia(data);
    if (turma.diasSemana.contains(dia)) return true;
    if (dia == 'Sab' && turma.diasSemana.contains('SÃ¡b')) return true;
    return false;
  }

  bool _podeReservarAgora(DTOTurma turma) {
    final inicio = _inicioAula(turma, _hoje);
    final limite = inicio.subtract(const Duration(minutes: 30));
    return !DateTime.now().isBefore(limite);
  }

  DateTime _inicioAula(DTOTurma turma, DateTime dataAula) {
    final partes = turma.horarioInicio.split(':');
    final h = partes.isNotEmpty ? int.tryParse(partes[0]) ?? 0 : 0;
    final m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return DateTime(dataAula.year, dataAula.month, dataAula.day, h, m);
  }

  String _formatarHora(DateTime data) {
    final h = data.hour.toString().padLeft(2, '0');
    final m = data.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

  bool _estaNaGrade(DTOPosicaoBike p, DTOTurma turma) {
    return p.fila >= 0 &&
        p.fila < turma.sala.numeroFilas &&
        p.coluna >= 0 &&
        p.coluna < turma.sala.numeroColunas;
  }

  bool _ehProfessora(DTOTurma turma, DTOPosicaoBike p) {
    return p.fila == 0 && p.coluna == turma.sala.posicaoProfessora;
  }

  bool _contido(List<DTOPosicaoBike> lista, DTOPosicaoBike alvo) {
    return lista.any((p) => p.fila == alvo.fila && p.coluna == alvo.coluna);
  }
}

class _CardTurmaCheckin extends StatelessWidget {
  final _ResumoTurmaHoje resumo;
  final VoidCallback aoAgir;

  const _CardTurmaCheckin({required this.resumo, required this.aoAgir});

  @override
  Widget build(BuildContext context) {
    final r = resumo;
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final lotada = r.vagas == 0;
    final temCheckin = r.meuCheckin != null;
    final temConflito = r.checkinConflitante != null;
    final podeAgir = r.podeReservarAgora && !temConflito;

    final String badgeLabel;
    final Color badgeCor;
    if (temCheckin) {
      badgeLabel = 'Reservado';
      badgeCor = cores.info;
    } else if (temConflito) {
      badgeLabel = 'Conflito';
      badgeCor = cores.textoSuave;
    } else if (!podeAgir) {
      badgeLabel = 'Aguardando';
      badgeCor = cores.alerta;
    } else if (lotada) {
      badgeLabel = 'Lotada';
      badgeCor = cores.erro;
    } else {
      badgeLabel = '${r.vagas}/${r.reservaveis} vagas';
      badgeCor = cores.sucesso;
    }

    final String rotuloAcao;
    final IconData iconeAcao;
    final Color corBotao;
    if (temCheckin) {
      rotuloAcao = 'Cancelar check-in';
      iconeAcao = Icons.cancel_rounded;
      corBotao = cores.erroForte;
    } else if (temConflito) {
      rotuloAcao = 'Horário ocupado';
      iconeAcao = Icons.event_busy;
      corBotao = cores.textoSuave;
    } else if (!podeAgir) {
      rotuloAcao = 'Aguarde...';
      iconeAcao = Icons.lock_clock;
      corBotao = cores.borda;
    } else if (lotada) {
      rotuloAcao = 'Entrar em fila de espera';
      iconeAcao = Icons.queue;
      corBotao = cores.primaria;
    } else {
      rotuloAcao = 'Check-in';
      iconeAcao = Icons.pin_drop;
      corBotao = cores.sucesso;
    }

    final String statusTexto;
    final Color statusCor;
    if (temCheckin) {
      statusTexto = 'Você já reservou uma bike para esta aula.';
      statusCor = cores.info;
    } else if (temConflito) {
      statusTexto =
          'Você já tem check-in em ${r.checkinConflitante!.turma.nome}.';
      statusCor = cores.textoSuave;
    } else if (podeAgir) {
      statusTexto = 'Reserva disponível agora.';
      statusCor = cores.sucesso;
    } else {
      statusTexto = 'Reserva abre 30 min antes da aula.';
      statusCor = cores.alerta;
    }

    final botaoAtivo = (podeAgir || temCheckin) && !temConflito;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.turma.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _Chip(label: badgeLabel, cor: badgeCor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LinhaInfo(
                        Icons.schedule_outlined,
                        r.turma.horarioInicio,
                      ),
                      const SizedBox(height: 3),
                      _LinhaInfo(Icons.room_outlined, r.turma.sala.nome),
                      const SizedBox(height: 3),
                      _LinhaInfo(
                        Icons.people_outline,
                        '${r.checkinsAtivos} confirmados',
                      ),
                    ],
                  ),
                ),
                if (!temCheckin && !temConflito)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!lotada)
                        Text(
                          '${r.vagas}/${r.reservaveis} vagas',
                          style: TextStyle(
                            color: cores.sucesso,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      if (r.filaEspera > 0)
                        Padding(
                          padding: EdgeInsets.only(top: lotada ? 0 : 2),
                          child: Text(
                            'Fila: ${r.filaEspera}',
                            style: TextStyle(
                              color: cores.textoSuave,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(statusTexto, style: TextStyle(color: statusCor, fontSize: 12)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: botaoAtivo ? aoAgir : null,
              icon: Icon(iconeAcao, size: 18),
              label: Text(rotuloAcao),
              style: ElevatedButton.styleFrom(
                backgroundColor: botaoAtivo ? corBotao : null,
                foregroundColor: Colors.white,
                elevation: botaoAtivo ? 1 : 0,
                shadowColor: corBotao.withValues(alpha: 0.35),
                disabledBackgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                disabledForegroundColor: cores.textoSuave,
                minimumSize: const Size.fromHeight(46),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _LinhaInfo(this.icone, this.texto);

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 13, color: cores.textoSuave),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color cor;

  const _Chip({required this.label, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        border: Border.all(color: cor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ResumoTurmaHoje {
  final DTOTurma turma;
  final int reservaveis;
  final int vagas;
  final int filaEspera;
  final int checkinsAtivos;
  final DTOCheckin? meuCheckin;
  final DTOCheckin? checkinConflitante;
  final bool podeReservarAgora;

  _ResumoTurmaHoje({
    required this.turma,
    required this.reservaveis,
    required this.vagas,
    required this.filaEspera,
    required this.checkinsAtivos,
    required this.meuCheckin,
    required this.checkinConflitante,
    required this.podeReservarAgora,
  });
}
