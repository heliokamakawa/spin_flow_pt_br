import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_aluno.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_avaliacao_musica.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_checkin.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_fila_espera_checkin.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_manutencao.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_posicao_bike.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_turma_mix.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_usuario.dart';
import 'package:spin_flow/excluir/configuracoes/sessao_usuario.dart';
import 'package:spin_flow/excluir/dto/dto_aluno.dart';
import 'package:spin_flow/excluir/dto/dto_bike.dart';
import 'package:spin_flow/excluir/dto/dto_checkin.dart';
import 'package:spin_flow/excluir/dto/dto_musica.dart';
import 'package:spin_flow/excluir/dto/dto_posicao_bike.dart';
import 'package:spin_flow/excluir/dto/dto_turma.dart';
import 'package:spin_flow/excluir/dto/dto_turma_mix.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';

class TelaMapaCheckin extends StatefulWidget {
  const TelaMapaCheckin({super.key});

  @override
  State<TelaMapaCheckin> createState() => _TelaMapaCheckinState();
}

class _TelaMapaCheckinState extends State<TelaMapaCheckin> {
  final DAOCheckin _daoCheckin = DAOCheckin();
  final DAOAluno _daoAluno = DAOAluno();
  final DAOManutencao _daoManutencao = DAOManutencao();
  final DAOPosicaoBike _daoPosicaoBike = DAOPosicaoBike();
  final DAOTurmaMix _daoTurmaMix = DAOTurmaMix();
  final DAOUsuario _daoUsuario = DAOUsuario();
  final DAOFilaEsperaCheckin _daoFilaEspera = DAOFilaEsperaCheckin();
  final DAOAvaliacaoMusica _daoAvaliacaoMusica = DAOAvaliacaoMusica();

  DTOTurma? _turma;
  DateTime? _data;
  DTOAluno? _alunoLogado;
  bool _carregando = true;
  List<DTOCheckin> _checkinsAtivos = [];
  List<DTOPosicaoBike> _posicoesBloqueadas = [];
  List<DTOPosicaoBike> _posicoesSala = [];
  DTOCheckin? _meuCheckin;
  DTOTurmaMix? _mixAtivo;
  String _nomeProfessora = 'Professora';
  int _filaEspera = 0;
  String? _erroCarregamento;
  int? _filaSelecionada;
  int? _colunaSelecionada;
  final Map<String, int> _avaliacoesMusicas = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_turma != null) return;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _turma = args?['turma'] as DTOTurma?;
    _data = args?['data'] as DateTime?;
    _carregar();
  }

  Future<void> _carregar() async {
    if (_turma == null || _data == null) {
      if (!mounted) return;
      setState(() {
        _erroCarregamento = 'Turma/data não informados para abrir o mapa.';
        _carregando = false;
      });
      return;
    }
    setState(() {
      _carregando = true;
      _erroCarregamento = null;
    });

    try {
      final aluno = await _buscarAlunoLogado();
      final checkins = await _daoCheckin.buscarAtivosPorTurmaData(
        turmaId: _turma!.id ?? 0,
        data: _data!,
      );
      final bikesBloqueadas = await _daoManutencao
          .buscarBikeIdsEmManutencaoAtiva();
      final posicoesBloqueadas = await _daoPosicaoBike.buscarPorBikeIds(
        bikesBloqueadas,
      );
      final posicoesSala = (await _daoPosicaoBike.buscarTodos())
          .where((p) => _estaNaGrade(p))
          .toList();
      final mix = await _daoTurmaMix.buscarAtivoPorTurma(
        _turma!.id ?? 0,
        data: _data!,
      );
      final professora = await _daoUsuario.buscarPrimeiraProfessoraAtiva();
      final fila = await _daoFilaEspera.buscarAtivosPorTurmaData(
        turmaId: _turma!.id ?? 0,
        data: _data!,
      );
      final avaliacoes = await _buscarAvaliacoesMusicas(aluno, mix);

      DTOCheckin? meu;
      if (aluno != null) {
        for (final c in checkins) {
          if (c.aluno.id == aluno.id) {
            meu = c;
            break;
          }
        }
      }

      if (!mounted) return;
      final selecao = _primeiraBikeLivre(
        turma: _turma!,
        posicoesSala: posicoesSala,
        posicoesBloqueadas: posicoesBloqueadas,
        checkins: checkins,
      );
      setState(() {
        _alunoLogado = aluno;
        _checkinsAtivos = checkins;
        _posicoesBloqueadas = posicoesBloqueadas;
        _posicoesSala = posicoesSala;
        _meuCheckin = meu;
        _mixAtivo = mix;
        _nomeProfessora = (professora?['nome'] as String?) ?? 'Professora';
        _filaEspera = fila.length;
        _filaSelecionada = meu == null ? selecao?.fila : null;
        _colunaSelecionada = meu == null ? selecao?.coluna : null;
        _avaliacoesMusicas
          ..clear()
          ..addAll(avaliacoes);
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroCarregamento = 'Erro ao carregar mapa da turma: $e';
        _carregando = false;
      });
    }
  }

  Future<DTOAluno?> _buscarAlunoLogado() async {
    final email = SessaoUsuario.email;
    if (email == null || email.isEmpty) return null;
    return _daoAluno.buscarPorEmailAtivo(email);
  }

  Future<Map<String, int>> _buscarAvaliacoesMusicas(
    DTOAluno? aluno,
    DTOTurmaMix? turmaMix,
  ) async {
    final alunoId = aluno?.id;
    final musicas = turmaMix?.mix.musicas ?? const <DTOMusica>[];
    if (alunoId == null || musicas.isEmpty) return {};

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

  DTOPosicaoBike? _posicaoBike(int fila, int coluna) {
    for (final p in _posicoesSala) {
      if (p.fila == fila && p.coluna == coluna) return p;
    }
    return null;
  }

  Future<void> _reservar(int fila, int coluna) async {
    if (_alunoLogado == null || _turma == null || _data == null) return;
    if (_meuCheckin != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Voce ja possui check-in ativo para esta turma e data.',
          ),
        ),
      );
      return;
    }

    final dto = DTOCheckin(
      aluno: _alunoLogado!,
      turma: _turma!,
      data: _data!,
      fila: fila,
      coluna: coluna,
      ativo: true,
    );

    try {
      await _daoCheckin.reservarComValidacao(dto);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _cancelarMeuCheckin() async {
    if (_meuCheckin?.id == null) return;
    await _daoCheckin.cancelar(_meuCheckin!.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Check-in cancelado. A fila de espera foi processada automaticamente.',
        ),
      ),
    );
    await _carregar();
  }

  Future<void> _entrarFilaDeEspera() async {
    if (_alunoLogado?.id == null || _turma?.id == null || _data == null) return;
    try {
      await _daoFilaEspera.entrarNaFila(
        alunoId: _alunoLogado!.id!,
        turmaId: _turma!.id!,
        data: _data!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aluno inserido na fila de espera desta turma.'),
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

  void _abrirModalMix() {
    if (_mixAtivo == null) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Mix da aula'),
          content: const Text('Nao ha mix ativo para esta turma.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final musicas = _mixAtivo!.mix.musicas;
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
                        _mixAtivo!.mix.nome,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: musicas.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (_, index) {
                            final m = musicas[index];
                            return ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${m.nome} (${m.artista.nome})',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildAvaliacaoMusica(
                                    musica: m,
                                    indice: index,
                                    atualizarModal: atualizarModal,
                                  ),
                                ],
                              ),
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

  Widget _buildAvaliacaoMusica({
    required DTOMusica musica,
    required int indice,
    required StateSetter atualizarModal,
  }) {
    final chave = _chaveAvaliacaoMusica(musica, indice);
    final avaliacao = _avaliacoesMusicas[chave] ?? 0;

    return Row(
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
            atualizarModal(() {});
          },
          icon: Icon(marcada ? Icons.star : Icons.star_border),
          color: CoresApp.energia,
          tooltip: '$valor estrela${valor == 1 ? '' : 's'}',
          constraints: const BoxConstraints.tightFor(width: 30, height: 36),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }),
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

  _EstadoPosicao _estadoPosicao(int fila, int coluna) {
    if (_turma == null) return _EstadoPosicao.livre;
    if (fila == 0 && coluna == _turma!.sala.posicaoProfessora) {
      return _EstadoPosicao.professora;
    }

    final posicao = _posicaoBike(fila, coluna);
    if (posicao == null) {
      return _EstadoPosicao.semBike;
    }

    final bloqueada = _posicoesBloqueadas.any(
      (p) => p.fila == fila && p.coluna == coluna,
    );
    if (bloqueada) return _EstadoPosicao.bloqueada;

    DTOCheckin? checkin;
    for (final item in _checkinsAtivos) {
      if (item.fila == fila && item.coluna == coluna) {
        checkin = item;
        break;
      }
    }
    if (checkin == null) return _EstadoPosicao.livre;
    if (_alunoLogado != null && checkin.aluno.id == _alunoLogado!.id) {
      return _EstadoPosicao.minha;
    }
    return _EstadoPosicao.ocupada;
  }

  int _livresReservaveis() {
    if (_turma == null) return 0;
    int livres = 0;
    for (int fila = 0; fila < _turma!.sala.numeroFilas; fila++) {
      for (int coluna = 0; coluna < _turma!.sala.numeroColunas; coluna++) {
        if (_estadoPosicao(fila, coluna) == _EstadoPosicao.livre) {
          livres++;
        }
      }
    }
    return livres;
  }

  _SelecaoBike? _primeiraBikeLivre({
    required DTOTurma turma,
    required List<DTOPosicaoBike> posicoesSala,
    required List<DTOPosicaoBike> posicoesBloqueadas,
    required List<DTOCheckin> checkins,
  }) {
    for (int fila = 0; fila < turma.sala.numeroFilas; fila++) {
      for (int coluna = 0; coluna < turma.sala.numeroColunas; coluna++) {
        if (fila == 0 && coluna == turma.sala.posicaoProfessora) continue;
        final temBike = posicoesSala.any(
          (p) => p.fila == fila && p.coluna == coluna,
        );
        if (!temBike) continue;
        final bloqueada = posicoesBloqueadas.any(
          (p) => p.fila == fila && p.coluna == coluna,
        );
        if (bloqueada) continue;
        final ocupada = checkins.any(
          (c) => c.fila == fila && c.coluna == coluna,
        );
        if (ocupada) continue;
        return _SelecaoBike(fila, coluna);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_erroCarregamento != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa da Aula'),
          actions: const [AcaoSairAppBar()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_erroCarregamento!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_turma == null || _data == null) {
      return const Scaffold(
        body: Center(child: Text('Dados de turma/data nao informados.')),
      );
    }

    final filas = _turma!.sala.numeroFilas;
    final colunas = _turma!.sala.numeroColunas;
    final livres = _livresReservaveis();
    final mapaInvalido = filas <= 0 || colunas <= 0 || _posicoesSala.isEmpty;
    final reservaLiberada = _reservaLiberadaAgora();
    final bikeSelecionada =
        _filaSelecionada == null || _colunaSelecionada == null
        ? null
        : _posicaoBike(_filaSelecionada!, _colunaSelecionada!)?.bike;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        actions: [
          IconButton(
            onPressed: _abrirModalMix,
            icon: const Icon(Icons.library_music),
          ),
          const AcaoSairAppBar(),
        ],
      ),
      bottomNavigationBar:
          mapaInvalido || _meuCheckin != null || livres == 0 || !reservaLiberada
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: bikeSelecionada == null
                        ? null
                        : () =>
                              _reservar(_filaSelecionada!, _colunaSelecionada!),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      bikeSelecionada == null
                          ? 'Selecione uma bike'
                          : 'Confirmar bike ${_numeroBike(bikeSelecionada)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _turma!.nome,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$_nomeProfessora - ${_turma!.sala.nome} - Hoje, '
            '${_turma!.horarioInicio} às ${_horarioFim()}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ResumoAula(
                  titulo: 'Vagas',
                  valor: '$livres de ${_totalReservavel()}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResumoAula(
                  titulo: 'Janela',
                  valor: '${_horarioAbertura()} as ${_turma!.horarioInicio}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Escolha sua bike',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'As bikes destacadas estao ocupadas. Selecione uma bike livre para continuar.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (_filaEspera > 0)
            Text(
              'Fila de espera: $_filaEspera aluno(s).',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          const SizedBox(height: 12),
          if (livres == 0)
            const Text(
              'Turma lotada no momento. Voce pode entrar na fila de espera.',
              style: TextStyle(color: CoresApp.erro),
            ),
          if (!reservaLiberada)
            const Text(
              'Reserva bloqueada: liberada somente 30 minutos antes do inicio da aula.',
              style: TextStyle(color: CoresApp.alerta),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: const [
              _Legenda(cor: CoresApp.bikeLivre, texto: 'Livre', borda: true),
              _Legenda(cor: CoresApp.bikeOcupada, texto: 'Ocupada'),
              _Legenda(cor: CoresApp.bikeManutencao, texto: 'Manutencao'),
              _Legenda(cor: CoresApp.bikeProfessora, texto: 'Professora'),
              _Legenda(cor: CoresApp.bikeMinhaReserva, texto: 'Minha reserva'),
            ],
          ),
          const SizedBox(height: 14),
          if (mapaInvalido)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 42,
                    color: CoresApp.alerta,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Turma sem mapa operacional configurado.\nNao e possivel reservar bike nesta turma.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colunas,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filas * colunas,
                  itemBuilder: (context, index) {
                    final fila = index ~/ colunas;
                    final coluna = index % colunas;
                    final estado = _estadoPosicao(fila, coluna);
                    final posicao = _posicaoBike(fila, coluna);
                    final bike = posicao?.bike;
                    final checkin = _checkinEm(fila, coluna);
                    final podeSelecionar =
                        estado == _EstadoPosicao.livre && reservaLiberada;
                    final selecionada =
                        _filaSelecionada == fila &&
                        _colunaSelecionada == coluna;

                    return _BikeMapa(
                      label: estado == _EstadoPosicao.professora
                          ? 'Prof'
                          : _numeroBike(bike),
                      estado: estado,
                      selecionada: selecionada,
                      aluno: checkin?.aluno.nome,
                      onTap: () {
                        if (podeSelecionar) {
                          setState(() {
                            _filaSelecionada = fila;
                            _colunaSelecionada = coluna;
                          });
                          return;
                        }
                        if (checkin != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bike ocupada por ${checkin.aluno.nome}.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 14),
          _buildMixCard(),
          if (_meuCheckin != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _cancelarMeuCheckin,
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar meu check-in'),
              ),
            ),
          if (_meuCheckin == null && livres == 0)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _entrarFilaDeEspera,
                icon: const Icon(Icons.queue),
                label: const Text('Entrar na fila de espera'),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMixCard() {
    final mix = _mixAtivo?.mix;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _abrirModalMix,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.library_music),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mix?.nome ?? 'Mix da aula',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    mix == null
                        ? 'Nao ha mix ativo para esta turma'
                        : '${mix.musicas.length} musicas - resistencia e sprint',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const Text('Ver', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  DTOCheckin? _checkinEm(int fila, int coluna) {
    for (final item in _checkinsAtivos) {
      if (item.fila == fila && item.coluna == coluna) return item;
    }
    return null;
  }

  int _totalReservavel() {
    if (_turma == null) return 0;
    var total = 0;
    for (int fila = 0; fila < _turma!.sala.numeroFilas; fila++) {
      for (int coluna = 0; coluna < _turma!.sala.numeroColunas; coluna++) {
        if (fila == 0 && coluna == _turma!.sala.posicaoProfessora) continue;
        final posicao = _posicaoBike(fila, coluna);
        if (posicao == null) continue;
        final bloqueada = _posicoesBloqueadas.any(
          (p) => p.fila == fila && p.coluna == coluna,
        );
        if (!bloqueada) total++;
      }
    }
    return total;
  }

  String _numeroBike(DTOBike? bike) {
    final id = bike?.id;
    if (id == null) return '--';
    return id.toString().padLeft(2, '0');
  }

  String _horarioAbertura() {
    final inicio = _inicioAula();
    final abertura = inicio.subtract(const Duration(minutes: 30));
    return _formatarHora(abertura);
  }

  String _horarioFim() {
    final fim = _inicioAula().add(Duration(minutes: _turma!.duracaoMinutos));
    return _formatarHora(fim);
  }

  DateTime _inicioAula() {
    final partes = _turma!.horarioInicio.split(':');
    final h = partes.isNotEmpty ? int.tryParse(partes[0]) ?? 0 : 0;
    final m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return DateTime(_data!.year, _data!.month, _data!.day, h, m);
  }

  String _formatarHora(DateTime data) {
    final h = data.hour.toString().padLeft(2, '0');
    final m = data.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _estaNaGrade(DTOPosicaoBike p) {
    if (_turma == null) return false;
    return p.fila >= 0 &&
        p.fila < _turma!.sala.numeroFilas &&
        p.coluna >= 0 &&
        p.coluna < _turma!.sala.numeroColunas;
  }

  bool _reservaLiberadaAgora() {
    if (_turma == null || _data == null) return false;
    final partes = _turma!.horarioInicio.split(':');
    final h = partes.isNotEmpty ? int.tryParse(partes[0]) ?? 0 : 0;
    final m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    final inicio = DateTime(_data!.year, _data!.month, _data!.day, h, m);
    final limite = inicio.subtract(const Duration(minutes: 30));
    return !DateTime.now().isBefore(limite);
  }
}

enum _EstadoPosicao { livre, ocupada, professora, minha, bloqueada, semBike }

class _SelecaoBike {
  final int fila;
  final int coluna;

  const _SelecaoBike(this.fila, this.coluna);
}

class _ResumoAula extends StatelessWidget {
  final String titulo;
  final String valor;

  const _ResumoAula({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CoresApp.superficie,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CoresApp.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(valor),
        ],
      ),
    );
  }
}

class _BikeMapa extends StatelessWidget {
  final String label;
  final _EstadoPosicao estado;
  final bool selecionada;
  final String? aluno;
  final VoidCallback onTap;

  const _BikeMapa({
    required this.label,
    required this.estado,
    required this.selecionada,
    required this.aluno,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = _corEstado(estado);
    final textoEscuro = _usaTextoEscuro(estado);
    final texto = estado == _EstadoPosicao.ocupada && aluno != null
        ? aluno!
        : label;
    final conteudo = Container(
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(10),
        border: _bordaEstado(estado, selecionada),
        boxShadow: selecionada
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          texto,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textoEscuro ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );

    return Tooltip(
      message: aluno == null ? label : '$label - $aluno',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: conteudo,
      ),
    );
  }

  Color _corEstado(_EstadoPosicao estado) {
    switch (estado) {
      case _EstadoPosicao.livre:
        return CoresApp.bikeLivre;
      case _EstadoPosicao.ocupada:
        return CoresApp.bikeOcupada;
      case _EstadoPosicao.professora:
        return CoresApp.bikeProfessora;
      case _EstadoPosicao.minha:
        return CoresApp.bikeMinhaReserva;
      case _EstadoPosicao.bloqueada:
        return CoresApp.bikeManutencao;
      case _EstadoPosicao.semBike:
        return Colors.black45;
    }
  }

  Border _bordaEstado(_EstadoPosicao estado, bool selecionada) {
    if (selecionada) {
      return Border.all(color: CoresApp.textoPrincipal, width: 3);
    }
    if (estado == _EstadoPosicao.livre) {
      return Border.all(color: CoresApp.bordaForte);
    }
    return Border.all(color: Colors.transparent, width: 0);
  }

  bool _usaTextoEscuro(_EstadoPosicao estado) {
    return estado == _EstadoPosicao.livre;
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;
  final bool borda;

  const _Legenda({required this.cor, required this.texto, this.borda = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: cor,
            border: borda ? Border.all(color: CoresApp.bordaForte) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }
}
