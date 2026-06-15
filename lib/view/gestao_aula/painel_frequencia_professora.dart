import 'package:flutter/material.dart';
import 'package:spin_flow/controller/controlador_operacao_aula.dart';
import 'package:spin_flow/controller/sessao_usuario.dart';
import 'package:spin_flow/domain/modelo/frequencia_aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'detalhe_aluno_professora.dart';

class TelaPainelFrequenciaProfessora extends StatefulWidget {
  const TelaPainelFrequenciaProfessora({super.key});

  @override
  State<TelaPainelFrequenciaProfessora> createState() =>
      _TelaPainelFrequenciaProfessoraState();
}

class _TelaPainelFrequenciaProfessoraState
    extends State<TelaPainelFrequenciaProfessora> {
  final _controlador = ControladorOperacaoAula();
  final _buscaController = TextEditingController();

  List<FrequenciaAluno> _todos = [];
  bool _carregando = true;
  String? _erro;
  String _busca = '';

  static const _top = 10;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final professoraId = SessaoUsuario.professoraId;
    if (professoraId == null) {
      setState(() {
        _erro = 'Sessão inválida.';
        _carregando = false;
      });
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _controlador.buscarAlunosPorProfessora(professoraId);
      if (!mounted) return;
      setState(() {
        _todos = lista;
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

  List<FrequenciaAluno> get _listaMostrada {
    if (_busca.trim().isEmpty) return _todos.take(_top).toList();
    final filtro = _busca.trim().toLowerCase();
    final comecam = _todos
        .where((f) => f.nomeAluno.toLowerCase().startsWith(filtro))
        .toList();
    final contem = _todos
        .where((f) =>
            !f.nomeAluno.toLowerCase().startsWith(filtro) &&
            f.nomeAluno.toLowerCase().contains(filtro))
        .toList();
    return [...comecam, ...contem];
  }

  String get _tituloLista {
    if (_busca.trim().isEmpty) return 'Top $_top mais frequentes';
    return 'Resultados para "$_busca"';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCampoBusca(),
          const Divider(height: 1),
          Expanded(child: _buildConteudo()),
        ],
      ),
    );
  }

  Widget _buildCampoBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Buscar aluno por nome...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _busca.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _buscaController.clear();
                    setState(() => _busca = '');
                  },
                )
              : null,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) => setState(() => _busca = v),
      ),
    );
  }

  Widget _buildConteudo() {
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

    if (_todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: CoresApp.textoFraco),
            SizedBox(height: 8),
            Text(
              'Nenhum aluno frequentou estas turmas ainda.',
              style: TextStyle(color: CoresApp.textoFraco),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final lista = _listaMostrada;

    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: CoresApp.textoFraco,
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum aluno encontrado para "$_busca".',
              style: const TextStyle(color: CoresApp.textoFraco),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(
            _tituloLista,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: lista.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: CoresApp.superficieSuave),
            itemBuilder: (_, i) => _buildItem(lista[i], i + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(FrequenciaAluno f, int posicao) {
    final iniciais = _iniciais(f.nomeAluno);
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: CoresApp.primaria,
        child: Text(
          iniciais,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        f.nomeAluno,
        style: const TextStyle(
          fontSize: 14,
          color: CoresApp.textoPrincipal,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: CoresApp.primariaSuave,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${f.totalCheckins} check-in${f.totalCheckins == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CoresApp.primaria,
          ),
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TelaDetalheAlunoProfessora(
            alunoId: f.alunoId,
            professoraId: SessaoUsuario.professoraId ?? 0,
          ),
        ),
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }
}
