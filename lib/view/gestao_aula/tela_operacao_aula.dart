import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/gestao_aula/controlador_operacao_aula.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';
import 'package:spin_flow/view/gestao_aula/tela_mapa_aula.dart';

class TelaOperacaoAula extends StatefulWidget {
  const TelaOperacaoAula({super.key});

  @override
  State<TelaOperacaoAula> createState() => _TelaOperacaoAulaState();
}

class _TelaOperacaoAulaState extends State<TelaOperacaoAula> {
  final _controlador = GetIt.I<ControladorOperacaoAula>();
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
        ),
      ),
    );
  }
}

class _CardTurma extends StatelessWidget {
  final ResumoTurmaHoje resumo;
  final VoidCallback onTap;

  const _CardTurma({required this.resumo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final turma = resumo.turma;
    final dias = turma.diasSemana.map((d) => d.dbValue).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            Text('Sala: ${resumo.nomeSala}'),
            Text('Dias: $dias'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
