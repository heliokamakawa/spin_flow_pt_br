import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_checkin_aluno.dart';
import 'package:spin_flow/domain/modelo/estado_mapa_aula.dart';
import 'package:spin_flow/domain/modelo/posicao_bike.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/tema_app.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/painel_mix.dart';

class TelaCheckin extends StatefulWidget {
  final int turmaId;
  final int alunoId;

  const TelaCheckin({
    super.key,
    required this.turmaId,
    required this.alunoId,
  });

  @override
  State<TelaCheckin> createState() => _TelaCheckinState();
}

class _TelaCheckinState extends State<TelaCheckin> {
  final _controlador = ControladorCheckinAluno();

  MapaCheckinAluno? _dados;
  bool _carregando = true;
  bool _agindo = false;

  PosicaoBike? _posicaoEscolhida;
  String? _tituloPainel;
  String? _subPainel;

  bool _filaExpandida = false;
  List<String>? _nomesNaFila;
  bool _carregandoFila = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _posicaoEscolhida = null;
      _tituloPainel = null;
      _subPainel = null;
      _filaExpandida = false;
      _nomesNaFila = null;
      _carregandoFila = false;
    });
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

  // -- Ações ------------------------------------------------------------------

  void _aoTocarCelula(MapaCheckinAluno dados, int fila, int coluna) {
    final estado = dados.mapa;

    if (estado.ehProfessora(fila, coluna)) {
      setState(() {
        _posicaoEscolhida = null;
        _tituloPainel = 'Bike da professora';
        _subPainel = null;
      });
      return;
    }

    final posicao = estado.posicaoEm(fila, coluna);
    if (posicao == null) return;

    if (estado.emManutencao(fila, coluna)) {
      final motivo = estado.motivoManutencaoEm(fila, coluna);
      setState(() {
        _posicaoEscolhida = null;
        _tituloPainel = 'Em manutenção';
        _subPainel = motivo?.isNotEmpty == true ? motivo : 'Sem descrição';
      });
      return;
    }

    final checkin = estado.checkinEm(fila, coluna);
    if (checkin != null && checkin.alunoId == dados.alunoId) {
      setState(() {
        _posicaoEscolhida = null;
        _tituloPainel = 'Sua reserva';
        _subPainel = posicao.bikeNome;
      });
      return;
    }

    if (checkin != null) {
      final partes = checkin.nomeAluno.trim().split(' ');
      final nome = partes.isNotEmpty ? partes.first : '—';
      setState(() {
        _posicaoEscolhida = null;
        _tituloPainel = nome;
        _subPainel = posicao.bikeNome;
      });
      return;
    }

    // bike livre — selecionar para check-in
    if (dados.idCheckinDoAluno == null &&
        dados.posicaoNaFila == null &&
        dados.janelAberta) {
      setState(() {
        _posicaoEscolhida = _posicaoEscolhida?.bikeNome == posicao.bikeNome
            ? null // deselect ao tocar de novo
            : posicao;
        _tituloPainel = null;
        _subPainel = null;
      });
    }
  }

  Future<void> _reservar() async {
    final posicao = _posicaoEscolhida;
    final dados = _dados;
    if (posicao == null || dados == null) return;

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

    if (resultado.sucesso) {
      Navigator.of(context).pop();
    } else {
      _snack(resultado.mensagemErro!, erro: true);
    }
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
              foregroundColor:
                  Theme.of(context).extension<CoresSemanticasApp>()!.erro,
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
    final dados = _dados;
    if (dados == null) return;
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dados.mapa.turma.nome),
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
    if (resultado.sucesso) {
      Navigator.of(context).pop();
    } else {
      _snack(resultado.mensagemErro!, erro: true);
    }
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

  Future<void> _toggleFila() async {
    if (_filaExpandida) {
      setState(() => _filaExpandida = false);
      return;
    }
    setState(() {
      _filaExpandida = true;
      _carregandoFila = _nomesNaFila == null;
    });
    if (_nomesNaFila == null) {
      final nomes = await _controlador.buscarNomesNaFila(widget.turmaId);
      if (!mounted) return;
      setState(() {
        _nomesNaFila = nomes;
        _carregandoFila = false;
      });
    }
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

  // -- UI ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _dados == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Erro ao carregar mapa.'),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _carregar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _buildConteudo(),
    );
  }

  Widget _buildConteudo() {
    final dados = _dados!;

    return _agindo
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dados.mix != null)
                  Card(
                    margin: EdgeInsets.zero,
                    child: PainelMix(
                      mix: dados.mix!,
                      onAvaliar: (musicaId, nota) =>
                          _controlador.avaliarMusica(widget.alunoId, musicaId, nota),
                    ),
                  ),
                if (dados.mix != null) const SizedBox(height: 8),
                _CabecalhoAula(dados: dados),
                const SizedBox(height: 10),
                _LegendaBikes(dados: dados),
                const SizedBox(height: 8),
                _GradeBikes(
                  dados: dados,
                  posicaoEscolhida: _posicaoEscolhida,
                  onTocar: (f, c) => _aoTocarCelula(dados, f, c),
                ),
                const SizedBox(height: 8),
                _PainelInfo(
                  titulo: _tituloPainel,
                  subtitulo: _subPainel,
                  posicaoEscolhida: _posicaoEscolhida,
                ),
                const SizedBox(height: 12),
                _BotaoAcao(
                  dados: dados,
                  posicaoEscolhida: _posicaoEscolhida,
                  onReservar: _reservar,
                  onCancelar: _cancelarMinha,
                  onEntrarFila: _entrarFilaEspera,
                  onSairFila: _sairDaFila,
                ),
                if (dados.lotada && dados.totalNaFila > 0) ...[
                  const SizedBox(height: 8),
                  _PainelFilaEspera(
                    total: dados.totalNaFila,
                    expandido: _filaExpandida,
                    carregando: _carregandoFila,
                    nomes: _nomesNaFila,
                    onToggle: _toggleFila,
                  ),
                ],
              ],
            ),
          );
  }
}

// -- Cabeçalho ---------------------------------------------------------------

class _CabecalhoAula extends StatelessWidget {
  final MapaCheckinAluno dados;

  const _CabecalhoAula({required this.dados});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final turma = dados.mapa.turma;
    final dias = turma.diasSemana.map((d) => d.dbValue).join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              turma.nome,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              [
                if (dados.nomeProfessora != null) dados.nomeProfessora!,
                '${turma.horarioInicio} · ${turma.duracaoMinutos} min',
              ].join(' · '),
              style: TextStyle(fontSize: 14, color: cores.textoSuave),
            ),
            if (dias.isNotEmpty)
              Text(
                dias,
                style: TextStyle(fontSize: 13, color: cores.textoFraco),
              ),
            const SizedBox(height: 6),
            _ResumoBikes(dados: dados),
          ],
        ),
      ),
    );
  }
}

// -- Resumo de bikes ---------------------------------------------------------

class _ResumoBikes extends StatelessWidget {
  final MapaCheckinAluno dados;

  const _ResumoBikes({required this.dados});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final mapa = dados.mapa;
    final disponiveis = mapa.totalBikes - mapa.checkinsAtivos.length;
    final manut = mapa.bikesEmManutencao;

    final partes = <String>[
      '$disponiveis de ${mapa.totalBikes} vagas disponíveis',
      if (manut > 0) '$manut em manutenção',
    ];

    return Text(
      partes.join(' · '),
      style: TextStyle(fontSize: 13, color: cores.textoFraco),
    );
  }
}

// -- Legenda -----------------------------------------------------------------

class _LegendaBikes extends StatelessWidget {
  final MapaCheckinAluno dados;

  const _LegendaBikes({required this.dados});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        _ItemLegenda(cor: cores.bikeMinhaReserva, texto: 'Minha reserva'),
        _ItemLegenda(cor: cores.bikeLivre, texto: 'Livre', borda: true),
        _ItemLegenda(cor: cores.bikeOcupada, texto: 'Ocupada'),
        _ItemLegenda(cor: cores.bikeProfessora, texto: 'Professora'),
        _ItemLegenda(cor: cores.bikeManutencao, texto: 'Manutenção'),
      ],
    );
  }
}

class _ItemLegenda extends StatelessWidget {
  final Color cor;
  final String texto;
  final bool borda;

  const _ItemLegenda({required this.cor, required this.texto, this.borda = false});

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
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// -- Grade de bikes ----------------------------------------------------------

class _GradeBikes extends StatelessWidget {
  final MapaCheckinAluno dados;
  final PosicaoBike? posicaoEscolhida;
  final void Function(int fila, int coluna) onTocar;

  const _GradeBikes({
    required this.dados,
    required this.posicaoEscolhida,
    required this.onTocar,
  });

  @override
  Widget build(BuildContext context) {
    final sala = dados.mapa.sala;

    return LayoutBuilder(
      builder: (_, constraints) {
        final cellSize = constraints.maxWidth / sala.numeroColunas;
        return SizedBox(
          height: cellSize * sala.numeroFilas,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: sala.numeroColunas,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: sala.numeroFilas * sala.numeroColunas,
            itemBuilder: (_, index) {
              final fila = index ~/ sala.numeroColunas;
              final coluna = index % sala.numeroColunas;
              return _buildCelula(context, fila, coluna);
            },
          ),
        );
      },
    );
  }

  Widget _buildCelula(BuildContext context, int fila, int coluna) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final estado = dados.mapa;

    if (estado.ehProfessora(fila, coluna)) {
      return _Celula(
        cor: cores.bikeProfessora,
        numero: 'P',
        onTap: () => onTocar(fila, coluna),
      );
    }

    final posicao = estado.posicaoEm(fila, coluna);
    if (posicao == null) {
      return _Celula(
        cor: cores.textoFraco.withValues(alpha: 0.15),
        numero: '—',
        textoEscuro: true,
      );
    }

    if (estado.emManutencao(fila, coluna)) {
      return _Celula(
        cor: cores.bikeManutencao,
        numero: posicao.numeroDisplay,
        onTap: () => onTocar(fila, coluna),
      );
    }

    final checkin = estado.checkinEm(fila, coluna);

    if (checkin != null && checkin.alunoId == dados.alunoId) {
      return _Celula(
        cor: cores.bikeMinhaReserva,
        numero: posicao.numeroDisplay,
        onTap: () => onTocar(fila, coluna),
      );
    }

    if (checkin != null) {
      return _Celula(
        cor: cores.bikeOcupada,
        numero: posicao.numeroDisplay,
        onTap: () => onTocar(fila, coluna),
      );
    }

    final selecionada = posicaoEscolhida?.bikeNome == posicao.bikeNome &&
        posicaoEscolhida?.fila == fila &&
        posicaoEscolhida?.coluna == coluna;

    return _Celula(
      cor: selecionada ? cores.bikeMinhaReserva : cores.bikeLivre,
      numero: posicao.numeroDisplay,
      textoEscuro: !selecionada,
      borda: !selecionada,
      selecionada: selecionada,
      onTap: () => onTocar(fila, coluna),
    );
  }
}

class _Celula extends StatelessWidget {
  final Color cor;
  final String numero;
  final VoidCallback? onTap;
  final bool textoEscuro;
  final bool borda;
  final bool selecionada;

  const _Celula({
    required this.cor,
    required this.numero,
    this.onTap,
    this.textoEscuro = false,
    this.borda = false,
    this.selecionada = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;
    final textoCor = textoEscuro
        ? CoresApp.textoPrincipal
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(8),
          border: selecionada
              ? Border.all(color: Colors.white, width: 2.5)
              : borda
                  ? Border.all(color: cores.borda)
                  : null,
        ),
        child: Center(
          child: Text(
            numero,
            style: TextStyle(
              color: textoCor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// -- Painel informativo ------------------------------------------------------

class _PainelInfo extends StatelessWidget {
  final String? titulo;
  final String? subtitulo;
  final PosicaoBike? posicaoEscolhida;

  const _PainelInfo({
    required this.titulo,
    required this.subtitulo,
    required this.posicaoEscolhida,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    final String textoTitulo;
    String? textoSub;
    IconData icone;
    Color corIcone;

    if (posicaoEscolhida != null) {
      textoTitulo = 'Bike selecionada para check-in';
      textoSub = posicaoEscolhida!.numeroDisplay;
      icone = Icons.check_circle_outline;
      corIcone = cores.sucesso;
    } else if (titulo == 'Em manutenção') {
      textoTitulo = titulo!;
      textoSub = subtitulo;
      icone = Icons.build_outlined;
      corIcone = cores.alerta;
    } else if (titulo == 'Sua reserva') {
      textoTitulo = titulo!;
      textoSub = subtitulo;
      icone = Icons.star_outline;
      corIcone = cores.info;
    } else if (titulo != null) {
      textoTitulo = titulo!;
      textoSub = subtitulo;
      icone = Icons.person_outline;
      corIcone = cores.textoSuave;
    } else {
      textoTitulo = 'Toque em uma bike para ver detalhes';
      icone = Icons.touch_app_outlined;
      corIcone = cores.textoFraco;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icone, size: 20, color: corIcone),
              const SizedBox(width: 10),
              Expanded(
                child: textoSub != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textoTitulo,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            textoSub,
                            style: TextStyle(
                              fontSize: 13,
                              color: cores.textoSuave,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        textoTitulo,
                        style: TextStyle(
                          fontSize: 14,
                          color: titulo == null ? cores.textoFraco : null,
                          fontStyle: titulo == null ? FontStyle.italic : null,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Botão de ação principal -------------------------------------------------

class _BotaoAcao extends StatelessWidget {
  final MapaCheckinAluno dados;
  final PosicaoBike? posicaoEscolhida;
  final VoidCallback onReservar;
  final VoidCallback onCancelar;
  final VoidCallback onEntrarFila;
  final VoidCallback onSairFila;

  const _BotaoAcao({
    required this.dados,
    required this.posicaoEscolhida,
    required this.onReservar,
    required this.onCancelar,
    required this.onEntrarFila,
    required this.onSairFila,
  });

  @override
  Widget build(BuildContext context) {
    if (dados.idCheckinDoAluno != null) {
      return _botao(
        label: 'Cancelar Reserva',
        cor: CoresApp.erro,
        onTap: onCancelar,
      );
    }

    if (dados.posicaoNaFila != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Você está na fila · posição ${dados.posicaoNaFila}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).extension<CoresSemanticasApp>()!.alerta,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _botao(label: 'Sair da Fila', cor: CoresApp.alerta, onTap: onSairFila),
        ],
      );
    }

    if (!dados.janelAberta) {
      return _botao(
        label: 'Aguardando · Abre 30 min antes',
        cor: CoresApp.superficieSuave,
        onTap: null,
        textoCor: CoresApp.textoFraco,
      );
    }

    if (dados.lotada) {
      return _botao(
        label: 'Entrar na Fila',
        cor: CoresApp.alerta,
        onTap: onEntrarFila,
      );
    }

    if (posicaoEscolhida != null) {
      return _botao(
        label: 'Confirmar Check-in',
        cor: CoresApp.sucesso,
        onTap: onReservar,
      );
    }

    return _botao(
      label: 'Selecione uma bike disponível',
      cor: CoresApp.superficieSuave,
      onTap: null,
      textoCor: CoresApp.textoFraco,
    );
  }

  Widget _botao({
    required String label,
    required Color cor,
    required VoidCallback? onTap,
    Color textoCor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: textoCor,
          disabledBackgroundColor: cor,
          disabledForegroundColor: textoCor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

// -- Painel fila de espera ---------------------------------------------------

class _PainelFilaEspera extends StatelessWidget {
  final int total;
  final bool expandido;
  final bool carregando;
  final List<String>? nomes;
  final VoidCallback onToggle;

  const _PainelFilaEspera({
    required this.total,
    required this.expandido,
    required this.carregando,
    required this.nomes,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 18, color: cores.alerta),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fila de espera · $total ${total == 1 ? 'pessoa' : 'pessoas'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cores.alerta,
                      ),
                    ),
                  ),
                  Icon(
                    expandido ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: cores.textoSuave,
                  ),
                ],
              ),
              if (expandido) ...[
                const SizedBox(height: 8),
                if (carregando)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (nomes != null)
                  ...nomes!.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
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
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
