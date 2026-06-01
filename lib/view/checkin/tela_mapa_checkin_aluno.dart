import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/checkin/controlador_checkin_aluno.dart';
import 'package:spin_flow/core/tema/tema_app.dart';
import 'package:spin_flow/model/gestao_aula/estado_mapa_aula.dart';
import 'package:spin_flow/model/gestao_aula/modelo_checkin.dart';
import 'package:spin_flow/model/gestao_aula/modelo_posicao_bike.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';

class TelaMapeamentoCheckinAluno extends StatefulWidget {
  final int turmaId;
  final String nomeTurma;
  final int alunoId;

  const TelaMapeamentoCheckinAluno({
    super.key,
    required this.turmaId,
    required this.nomeTurma,
    required this.alunoId,
  });

  @override
  State<TelaMapeamentoCheckinAluno> createState() =>
      _TelaMapeamentoCheckinAlunoState();
}

class _TelaMapeamentoCheckinAlunoState
    extends State<TelaMapeamentoCheckinAluno> {
  final _controlador = GetIt.I<ControladorCheckinAluno>();
  MapaCheckinAluno? _dados;
  bool _carregando = true;
  bool _agindo = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final dados = await _controlador.carregarMapa(
        widget.turmaId,
        widget.alunoId,
      );
      if (!mounted) return;
      setState(() {
        _dados = dados;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      _snack('Erro ao carregar mapa: $e', erro: true);
    }
  }

  // ── Ações ──────────────────────────────────────────────────────────────────

  Future<void> _reservar(ModeloPosicaoBike posicao) async {
    final dados = _dados!;
    if (!dados.janelAberta) {
      _snack('Reservas abertas 30 min antes da aula.');
      return;
    }
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(posicao.bikeNome),
        content: const Text('Reservar esta bike?'),
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

    setState(() => _agindo = true);
    final agora = DateTime.now();
    final resultado = await _controlador.reservar(
      alunoId: widget.alunoId,
      turma: dados.mapa.turma,
      data: DateTime(agora.year, agora.month, agora.day),
      fila: posicao.fila,
      coluna: posicao.coluna,
    );
    if (!mounted) return;
    setState(() => _agindo = false);
    _snack(
      resultado.sucesso ? 'Reserva confirmada!' : resultado.mensagemErro!,
      erro: !resultado.sucesso,
    );
    if (resultado.sucesso) await _carregar();
  }

  Future<void> _cancelarMinha() async {
    final id = _dados?.idCheckinDoAluno;
    if (id == null) return;
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Cancelar sua reserva?'),
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

    setState(() => _agindo = true);
    final resultado = await _controlador.cancelarMinha(id);
    if (!mounted) return;
    setState(() => _agindo = false);
    _snack(
      resultado.sucesso ? 'Reserva cancelada.' : resultado.mensagemErro!,
      erro: !resultado.sucesso,
    );
    if (resultado.sucesso) await _carregar();
  }

  Future<void> _entrarFilaEspera() async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.nomeTurma),
        content: const Text('Entrar na fila de espera?'),
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

    setState(() => _agindo = true);
    final agora = DateTime.now();
    final resultado = await _controlador.entrarFilaEspera(
      widget.alunoId,
      widget.turmaId,
      DateTime(agora.year, agora.month, agora.day),
    );
    if (!mounted) return;
    setState(() => _agindo = false);
    _snack(
      resultado.sucesso ? 'Você entrou na fila!' : resultado.mensagemErro!,
      erro: !resultado.sucesso,
    );
    if (resultado.sucesso) await _carregar();
  }

  Future<void> _sairDaFila() async {
    final filaId = _dados?.filaId;
    if (filaId == null) return;
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Sair da fila de espera?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirma != true || !mounted) return;

    setState(() => _agindo = true);
    final resultado = await _controlador.sairDaFila(filaId);
    if (!mounted) return;
    setState(() => _agindo = false);
    _snack(
      resultado.sucesso ? 'Saiu da fila.' : resultado.mensagemErro!,
      erro: !resultado.sucesso,
    );
    if (resultado.sucesso) await _carregar();
  }

  void _snack(String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro
            ? Theme.of(context).extension<CoresSemanticasApp>()!.erro
            : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeTurma),
        actions: [const AcaoSairAppBar()],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _dados == null
          ? const Center(child: Text('Erro ao carregar.'))
          : _buildConteudo(),
    );
  }

  Widget _buildConteudo() {
    final dados = _dados!;
    final sala = dados.mapa.sala;

    return Column(
      children: [
        _buildLegenda(dados),
        Expanded(
          child: _agindo
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: sala.numeroColunas,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: sala.numeroFilas * sala.numeroColunas,
                  itemBuilder: (_, index) {
                    final fila = index ~/ sala.numeroColunas;
                    final coluna = index % sala.numeroColunas;
                    return _buildCelula(dados, fila, coluna);
                  },
                ),
        ),
        _buildBarraAcoes(dados),
      ],
    );
  }

  Widget _buildCelula(MapaCheckinAluno dados, int fila, int coluna) {
    final estado = dados.mapa;
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    if (estado.ehProfessora(fila, coluna)) {
      return _Celula(
        cor: cores.bikeProfessora,
        label: 'Profa',
        sub: 'F${fila + 1}C${coluna + 1}',
      );
    }

    final posicao = estado.posicaoEm(fila, coluna);
    if (posicao == null) {
      return _Celula(
        cor: cores.textoFraco.withValues(alpha: 0.18),
        label: '—',
        sub: 'F${fila + 1}C${coluna + 1}',
        textEscuro: true,
      );
    }

    if (estado.emManutencao(fila, coluna)) {
      return _Celula(
        cor: cores.bikeManutencao,
        label: 'Manut',
        sub: posicao.bikeNome,
      );
    }

    final checkin = estado.checkinEm(fila, coluna);

    if (checkin != null && checkin.alunoId == dados.alunoId) {
      return _Celula(
        cor: cores.bikeMinhaReserva,
        label: 'Minha',
        sub: posicao.bikeNome,
        onTap: _cancelarMinha,
      );
    }

    if (checkin != null) {
      return _Celula(
        cor: cores.bikeOcupada,
        label: _primeiroNome(checkin),
        sub: posicao.bikeNome,
      );
    }

    return _Celula(
      cor: cores.bikeLivre,
      label: posicao.bikeNome,
      sub: 'F${fila + 1}C${coluna + 1}',
      textEscuro: true,
      borda: true,
      onTap: () => _reservar(posicao),
    );
  }

  String _primeiroNome(ModeloCheckin c) {
    final partes = c.nomeAluno.trim().split(' ');
    return partes.isNotEmpty ? partes.first : '—';
  }

  Widget _buildLegenda(MapaCheckinAluno dados) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        children: [
          _ItemLegenda(cor: cores.bikeMinhaReserva, texto: 'Minha reserva'),
          _ItemLegenda(cor: cores.bikeLivre, texto: 'Livre', borda: true),
          _ItemLegenda(cor: cores.bikeOcupada, texto: 'Ocupada'),
          _ItemLegenda(cor: cores.bikeProfessora, texto: 'Professora'),
          if (!dados.janelAberta)
            _ItemLegenda(cor: cores.bikeManutencao, texto: 'Janela fechada'),
        ],
      ),
    );
  }

  Widget _buildBarraAcoes(MapaCheckinAluno dados) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    Widget conteudo;

    if (dados.idCheckinDoAluno != null) {
      conteudo = TextButton.icon(
        onPressed: _cancelarMinha,
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancelar minha reserva'),
        style: TextButton.styleFrom(foregroundColor: cores.erro),
      );
    } else if (dados.posicaoNaFila != null) {
      conteudo = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fila de espera: ${dados.posicaoNaFila}ª posição',
            style: TextStyle(color: cores.alerta, fontWeight: FontWeight.w600),
          ),
          TextButton(onPressed: _sairDaFila, child: const Text('Sair')),
        ],
      );
    } else if (!dados.janelAberta) {
      conteudo = Text(
        'Reservas abertas 30 min antes do início.',
        style: TextStyle(color: cores.textoSuave),
        textAlign: TextAlign.center,
      );
    } else if (dados.lotada) {
      conteudo = SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _entrarFilaEspera,
          icon: const Icon(Icons.queue),
          label: const Text('Entrar na fila de espera'),
        ),
      );
    } else {
      conteudo = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: conteudo,
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _Celula extends StatelessWidget {
  final Color cor;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  final bool textEscuro;
  final bool borda;

  const _Celula({
    required this.cor,
    required this.label,
    required this.sub,
    this.onTap,
    this.textEscuro = false,
    this.borda = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final ct = textEscuro
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
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sub,
              style: TextStyle(
                color: ct,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: ct, fontSize: 10),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            border: borda ? Border.all(color: cores.borda) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
