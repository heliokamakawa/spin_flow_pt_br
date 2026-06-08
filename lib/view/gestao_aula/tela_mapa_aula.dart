import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_operacao_aula.dart';
import 'package:spin_flow/view/componentes/painel_instagram.dart';
import 'package:spin_flow/view/componentes/tema_app.dart';
import 'package:spin_flow/domain/modelo/mix.dart';
import 'package:spin_flow/domain/modelo/tipo_manutencao.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/domain/modelo/checkin.dart';
import 'package:spin_flow/domain/modelo/posicao_bike.dart';
import 'package:spin_flow/domain/modelo/turma.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class TelaMapeamentoAula extends StatefulWidget {
  final int turmaId;
  final String nomeTurma;

  const TelaMapeamentoAula({
    super.key,
    required this.turmaId,
    required this.nomeTurma,
  });

  @override
  State<TelaMapeamentoAula> createState() => _TelaMapeamentoAulaState();
}

class _TelaMapeamentoAulaState extends State<TelaMapeamentoAula> {
  final _controlador = ControladorOperacaoAula();

  EstadoMapaAula? _estado;
  List<TipoManutencao> _tipos = [];
  List<Mix> _mixes = [];
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
        _controlador.carregarMapa(widget.turmaId),
        _controlador.listarTiposManutencao(),
        _controlador.listarMixes(),
      ]);
      if (!mounted) return;
      setState(() {
        _estado = results[0] as EstadoMapaAula;
        _tipos  = results[1] as List<TipoManutencao>;
        _mixes  = results[2] as List<Mix>;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar mapa: $e';
        _carregando = false;
      });
    }
  }

  // -- Ações ------------------------------------------------------------------

  Future<void> _alterarMix(int? novoMixId) async {
    final resultado = await _controlador.alterarMixTurma(widget.turmaId, novoMixId);
    if (!mounted) return;
    if (!resultado.sucesso) {
      _mostrarFeedback(resultado.mensagemErro!, erro: true);
      return;
    }
    final turmaAtual = _estado!.turma;
    setState(() {
      _estado = EstadoMapaAula(
        turma: Turma(
          id: turmaAtual.id,
          nome: turmaAtual.nome,
          horarioInicio: turmaAtual.horarioInicio,
          duracaoMinutos: turmaAtual.duracaoMinutos,
          diasSemana: turmaAtual.diasSemana,
          salaId: turmaAtual.salaId,
          professoraId: turmaAtual.professoraId,
          mixId: novoMixId,
          ativo: turmaAtual.ativo,
        ),
        sala: _estado!.sala,
        posicoes: _estado!.posicoes,
        checkinsAtivos: _estado!.checkinsAtivos,
        bikeIdsEmManutencao: _estado!.bikeIdsEmManutencao,
        motivosManutencao: _estado!.motivosManutencao,
      );
    });
    _mostrarFeedback('Mix atualizado.');
  }

  Future<void> _confirmarCancelamento(Checkin checkin) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(checkin.nomeAluno),
        content: const Text('Cancelar reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(
                context,
              ).extension<CoresSemanticasApp>()!.erro,
            ),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (confirma != true || !mounted) return;

    final resultado = await _controlador.cancelarCheckin(checkin.id!);
    if (!mounted) return;
    _mostrarFeedback(
      resultado.sucesso ? 'Reserva cancelada.' : resultado.mensagemErro!,
      erro: !resultado.sucesso,
    );
    if (resultado.sucesso) await _carregar();
  }

  Future<void> _resolverManutencao(PosicaoBike posicao) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(posicao.bikeNome),
        content: const Text('Marcar como boa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    if (confirma != true || !mounted) return;

    final resultado = await _controlador.resolverManutencao(posicao.bikeId!);
    if (!mounted) return;
    _mostrarFeedback(
      resultado.sucesso ? 'Bike liberada.' : resultado.mensagemErro!,
      erro: !resultado.sucesso,
    );
    if (resultado.sucesso) await _carregar();
  }

  void _mostrarFeedback(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro
            ? Theme.of(context).extension<CoresSemanticasApp>()!.erro
            : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _abrirModalManutencao(PosicaoBike posicao) async {
    final bikeId = posicao.bikeId;
    if (bikeId == null) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => _DialogManutencao(
        bikeNome: posicao.bikeNome,
        tipos: _tipos,
        onSalvar: (tipoId, descricao) async {
          Navigator.pop(ctx);
          final resultado = await _controlador.registrarManutencao(
            bikeId: bikeId,
            tipoManutencaoId: tipoId,
            descricao: descricao,
          );
          if (!mounted) return;
          if (!resultado.sucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resultado.mensagemErro!),
                backgroundColor: Theme.of(
                  context,
                ).extension<CoresSemanticasApp>()!.erro,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manutenção registrada.')),
            );
            await _carregar();
          }
        },
      ),
    );
  }

  // -- UI ---------------------------------------------------------------------

  Future<void> _abrirPainelInstagram() async {
    final participantes = _estado!.checkinsAtivos
        .map((c) => ParticipanteInstagram(nome: c.nomeAluno, instagram: c.instagramAluno))
        .toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PainelInstagram(participantes: participantes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temCheckins = _estado != null && _estado!.checkinsAtivos.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: [
          if (temCheckins)
            IconButton(
              icon: const Icon(Icons.alternate_email),
              tooltip: 'Marcações Instagram',
              onPressed: _abrirPainelInstagram,
            ),
          const AcaoSairAppBar(),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
          ? Center(child: Text(_erro!))
          : _buildConteudo(),
    );
  }

  Widget _buildSeletorMix() {
    final mixAtualId = _estado!.turma.mixId;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.queue_music, size: 18),
          const SizedBox(width: 6),
          const Text('Mix:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: mixAtualId,
                isExpanded: true,
                hint: const Text('Nenhum mix'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Nenhum'),
                  ),
                  ..._mixes.map(
                    (m) => DropdownMenuItem<int?>(
                      value: m.id,
                      child: Text(m.nome, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: _alterarMix,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    final estado = _estado!;
    final sala = estado.sala;
    final filas = sala.numeroFilas;
    final colunas = sala.numeroColunas;

    return Column(
      children: [
        _buildLegenda(),
        _buildSeletorMix(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colunas,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: filas * colunas,
            itemBuilder: (_, index) {
              final fila = index ~/ colunas;
              final coluna = index % colunas;
              return _buildCelula(estado, fila, coluna);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCelula(EstadoMapaAula estado, int fila, int coluna) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    if (estado.ehProfessora(fila, coluna)) {
      return _Celula(
        cor: cores.bikeProfessora,
        label: 'Profa',
        subLabel: 'F${fila + 1}C${coluna + 1}',
        onTap: null,
      );
    }

    final posicao = estado.posicaoEm(fila, coluna);
    if (posicao == null) {
      return _Celula(
        cor: cores.textoFraco.withValues(alpha: 0.18),
        label: '—',
        subLabel: 'F${fila + 1}C${coluna + 1}',
        onTap: null,
        textEscuro: true,
      );
    }

    if (estado.emManutencao(fila, coluna)) {
      return _Celula(
        cor: cores.bikeManutencao,
        label: 'Manut',
        subLabel: posicao.bikeNome,
        onTap: () => _resolverManutencao(posicao),
      );
    }

    final checkin = estado.checkinEm(fila, coluna);
    if (checkin != null) {
      return _Celula(
        cor: cores.bikeOcupada,
        label: checkin.nomeAluno,
        subLabel: 'F${fila + 1}C${coluna + 1}',
        onTap: () => _confirmarCancelamento(checkin),
      );
    }

    return _Celula(
      cor: cores.bikeLivre,
      label: posicao.bikeNome,
      subLabel: 'F${fila + 1}C${coluna + 1}',
      onTap: () => _abrirModalManutencao(posicao),
      textEscuro: true,
      borda: true,
    );
  }

  Widget _buildLegenda() {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        children: [
          _ItemLegenda(cor: cores.bikeProfessora, texto: 'Professora'),
          _ItemLegenda(cor: cores.bikeOcupada, texto: 'Reservada'),
          _ItemLegenda(cor: cores.bikeLivre, texto: 'Livre', borda: true),
          _ItemLegenda(cor: cores.bikeManutencao, texto: 'Manutenção'),
        ],
      ),
    );
  }
}

// -- Widgets auxiliares ------------------------------------------------------

class _Celula extends StatelessWidget {
  final Color cor;
  final String label;
  final String subLabel;
  final VoidCallback? onTap;
  final bool textEscuro;
  final bool borda;

  const _Celula({
    required this.cor,
    required this.label,
    required this.subLabel,
    required this.onTap,
    this.textEscuro = false,
    this.borda = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final corTexto = textEscuro
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(8),
          border: borda ? Border.all(color: cores.borda) : null,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subLabel,
              style: TextStyle(
                color: corTexto,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: corTexto, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemLegenda extends StatelessWidget {
  final Color cor;
  final String texto;
  final bool borda;

  const _ItemLegenda({
    required this.cor,
    required this.texto,
    this.borda = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: cor,
            border: borda ? Border.all(color: cores.borda) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _DialogManutencao extends StatefulWidget {
  final String bikeNome;
  final List<TipoManutencao> tipos;
  final void Function(int tipoId, String descricao) onSalvar;

  const _DialogManutencao({
    required this.bikeNome,
    required this.tipos,
    required this.onSalvar,
  });

  @override
  State<_DialogManutencao> createState() => _DialogManutencaoState();
}

class _DialogManutencaoState extends State<_DialogManutencao> {
  int? _tipoId;
  final _descricaoCtrl = TextEditingController();
  String? _erroTipo;

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    final erroTipo = _tipoId == null ? 'Selecione o tipo.' : null;
    setState(() => _erroTipo = erroTipo);
    if (erroTipo != null) return;
    widget.onSalvar(_tipoId!, _descricaoCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bikeNome),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Tipo',
              errorText: _erroTipo,
              isDense: true,
            ),
            items: widget.tipos.map((t) {
              return DropdownMenuItem(value: t.id, child: Text(t.nome));
            }).toList(),
            onChanged: (v) => setState(() {
              _tipoId = v;
              _erroTipo = null;
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descricaoCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Motivo',
              hintText: 'Ex.: pedal solto',
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Não'),
        ),
        TextButton(onPressed: _salvar, child: const Text('Registrar')),
      ],
    );
  }
}

