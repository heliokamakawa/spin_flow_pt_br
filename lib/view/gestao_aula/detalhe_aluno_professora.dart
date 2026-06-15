import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_operacao_aula.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/domain/modelo/turma_aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class TelaDetalheAlunoProfessora extends StatefulWidget {
  final int alunoId;
  final int professoraId;

  const TelaDetalheAlunoProfessora({
    super.key,
    required this.alunoId,
    required this.professoraId,
  });

  @override
  State<TelaDetalheAlunoProfessora> createState() =>
      _TelaDetalheAlunoProfessoraState();
}

class _TelaDetalheAlunoProfessoraState
    extends State<TelaDetalheAlunoProfessora> {
  final _controlador = ControladorOperacaoAula();

  Aluno? _aluno;
  List<TurmaAluno> _turmas = [];
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
      final results = await Future.wait([
        _controlador.buscarAlunoPorId(widget.alunoId),
        _controlador.buscarTurmasFrequentadasPorAluno(
          widget.alunoId,
          widget.professoraId,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _aluno = results[0] as Aluno?;
        _turmas = results[1] as List<TurmaAluno>;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar dados: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!, style: const TextStyle(color: CoresApp.erro)),
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

    if (_aluno == null) {
      return const Center(
        child: Text(
          'Aluno não encontrado.',
          style: TextStyle(color: CoresApp.textoFraco),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSecaoDados(_aluno!),
          const SizedBox(height: 12),
          _buildSecaoTurmas(),
        ],
      ),
    );
  }

  Widget _buildSecaoDados(Aluno aluno) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: CoresApp.primaria,
                  child: Text(
                    _iniciais(aluno.nome),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    aluno.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CoresApp.textoPrincipal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _info('Data de nascimento', _formatarData(aluno.dataNascimento)),
            _info('Gênero', _formatarGenero(aluno.genero)),
            _info('Telefone', aluno.telefone),
            _info('E-mail', aluno.email),
            _info('Instagram', aluno.instagram),
            _info('Facebook', aluno.facebook),
            _info('TikTok', aluno.tiktok),
            if (aluno.observacoes.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                'Observações',
                style: TextStyle(
                  fontSize: 12,
                  color: CoresApp.textoFraco,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                aluno.observacoes,
                style: const TextStyle(
                  fontSize: 14,
                  color: CoresApp.textoSuave,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoTurmas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Turmas frequentadas',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: CoresApp.textoPrincipal,
              ),
            ),
            const SizedBox(height: 12),
            if (_turmas.isEmpty)
              const Text(
                'Nenhuma turma registrada.',
                style: TextStyle(color: CoresApp.textoFraco, fontSize: 14),
              )
            else
              ...List.generate(_turmas.length, (i) {
                final t = _turmas[i];
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(height: 1, color: CoresApp.superficieSuave),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 18,
                            color: CoresApp.primaria,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.nome,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CoresApp.textoPrincipal,
                                  ),
                                ),
                                Text(
                                  t.horarioInicio,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: CoresApp.textoFraco,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: CoresApp.primariaSuave,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${t.totalCheckins} ×',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: CoresApp.primaria,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String valor) {
    final texto = valor.trim().isEmpty ? '—' : valor.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CoresApp.textoFraco,
              ),
            ),
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                color: CoresApp.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  String _formatarGenero(String genero) {
    switch (genero.toLowerCase()) {
      case 'masculino':
        return 'Masculino';
      case 'feminino':
        return 'Feminino';
      case 'outro':
        return 'Outro';
      default:
        return '—';
    }
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }
}
