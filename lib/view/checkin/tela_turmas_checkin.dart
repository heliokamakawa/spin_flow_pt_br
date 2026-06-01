import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/checkin/controlador_checkin_aluno.dart';
import 'package:spin_flow/core/autenticacao/sessao_usuario.dart';
import 'package:spin_flow/core/tema/tema_app.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';
import 'package:spin_flow/model/modelo/modelo_aluno.dart';
import 'package:spin_flow/view/checkin/tela_mapa_checkin_aluno.dart';

class TelaTurmasCheckin extends StatefulWidget {
  const TelaTurmasCheckin({super.key});

  @override
  State<TelaTurmasCheckin> createState() => _TelaTurmasCheckinState();
}

class _TelaTurmasCheckinState extends State<TelaTurmasCheckin> {
  final _controlador = GetIt.I<ControladorCheckinAluno>();

  ModeloAluno? _aluno;
  List<ResumoTurmaCheckin> _resumos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final email = SessaoUsuario.email;
    if (email == null) {
      setState(() {
        _erro = 'Sessão expirada.';
        _carregando = false;
      });
      return;
    }
    final aluno = await _controlador.buscarAlunoPorEmail(email);
    if (!mounted) return;
    if (aluno == null) {
      setState(() {
        _erro = 'Aluno não encontrado para este usuário.';
        _carregando = false;
      });
      return;
    }
    setState(() => _aluno = aluno);
    await _carregar();
  }

  Future<void> _carregar() async {
    final aluno = _aluno;
    if (aluno?.id == null) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _controlador.listarTurmasHoje(aluno!.id!);
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

  @override
  Widget build(BuildContext context) {
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

    if (_resumos.isEmpty) {
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
        itemCount: _resumos.length,
        itemBuilder: (_, i) => _CardCheckin(
          resumo: _resumos[i],
          onTap: () async {
            final aluno = _aluno!;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TelaMapeamentoCheckinAluno(
                  turmaId: _resumos[i].turma.id!,
                  nomeTurma: _resumos[i].turma.nome,
                  alunoId: aluno.id!,
                ),
              ),
            );
            await _carregar();
          },
        ),
      ),
    );
  }
}

// ── Card ────────────────────────────────────────────────────────────────────

class _CardCheckin extends StatelessWidget {
  final ResumoTurmaCheckin resumo;
  final VoidCallback onTap;

  const _CardCheckin({required this.resumo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.extension<CoresSemanticasApp>()!;
    final turma = resumo.turma;
    final badge = _badge(cores);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      turma.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  _Chip(label: badge.$1, cor: badge.$2),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${turma.horarioInicio} · ${turma.duracaoMinutos} min · ${resumo.nomeSala}',
                style: TextStyle(fontSize: 13, color: cores.textoSuave),
              ),
              const SizedBox(height: 4),
              _statusExtra(tema),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _badge(CoresSemanticasApp cores) {
    if (resumo.alunoJaTemCheckin) return ('Reservado', cores.info);
    if (resumo.alunoNaFila) {
      return ('Fila #${resumo.posicaoNaFila}', cores.alerta);
    }
    if (!resumo.janelAberta) return ('Aguardando', cores.textoSuave);
    if (resumo.lotada) return ('Lotada', cores.erro);
    return ('${resumo.vagasDisponiveis} vagas', cores.sucesso);
  }

  Widget _statusExtra(ThemeData tema) {
    final cores = tema.extension<CoresSemanticasApp>()!;

    if (resumo.alunoJaTemCheckin) {
      return Text(
        'Sua reserva esta confirmada.',
        style: TextStyle(color: cores.info, fontSize: 12),
      );
    }
    if (resumo.alunoNaFila) {
      return Text(
        'Você está na fila de espera (posição ${resumo.posicaoNaFila}).',
        style: TextStyle(color: cores.alerta, fontSize: 12),
      );
    }
    if (!resumo.janelAberta) {
      return Text(
        'Reserva disponível 30 min antes do início.',
        style: TextStyle(color: cores.textoSuave, fontSize: 12),
      );
    }
    if (resumo.lotada) {
      return Text(
        'Turma sem vagas. Toque para entrar na fila.',
        style: TextStyle(color: cores.erro, fontSize: 12),
      );
    }
    return Text(
      '${resumo.vagasDisponiveis} de ${resumo.totalBikes} bikes disponíveis.',
      style: TextStyle(color: cores.sucesso, fontSize: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
