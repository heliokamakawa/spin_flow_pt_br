import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_manutencao.dart';
import 'package:spin_flow/domain/modelo/manutencao.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/campo_busca.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'form_manutencao.dart';

class ListaManutencoes extends StatefulWidget {
  const ListaManutencoes({super.key});

  @override
  State<ListaManutencoes> createState() => _ListaManutencoesState();
}

class _ListaManutencoesState extends State<ListaManutencoes> {
  final _controlador = ControladorManutencao();
  final _buscaController = TextEditingController();
  late Future<List<Manutencao>> _futuro;

  static final _fmt = DateFormat('dd/MM/yyyy', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() => setState(() {}));
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _carregar() {
    setState(() {
      _futuro = _controlador.listar();
    });
  }

  Future<void> _abrirForm([Manutencao? manutencao]) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormManutencao(manutencao: manutencao)),
    );
    if (atualizado == true) _carregar();
  }

  List<Manutencao> _filtrar(List<Manutencao> todas) => filtrarComPrioridade(
    todas,
    _buscaController.text,
    (m) => [
      'Bike #${m.bikeId}',
      m.descricao,
      m.estadoOperacional.rotulo,
    ],
  );

  Future<void> _excluir(Manutencao manutencao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar manutenção'),
        content: const Text('Deseja cancelar esta manutenção?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim', style: TextStyle(color: CoresApp.erro)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      final resultado = await _controlador.excluir(manutencao.id!);
      if (!mounted) return;
      if (!resultado.sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado.mensagemErro!), backgroundColor: CoresApp.erro),
        );
        return;
      }
      _carregar();
    }
  }

  Color _corEstado(EstadoOperacional estado) => switch (estado) {
    EstadoOperacional.pendente => CoresApp.alerta,
    EstadoOperacional.emAndamento => CoresApp.info,
    EstadoOperacional.realizado => CoresApp.sucesso,
    EstadoOperacional.cancelado => CoresApp.textoFraco,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: [const AcaoSairAppBar()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CampoBusca(controlador: _buscaController, dica: 'Buscar bike, descrição ou estado...'),
          Expanded(
            child: FutureBuilder<List<Manutencao>>(
              future: _futuro,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todas = snapshot.data ?? [];
                if (todas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.build_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma manutenção registrada',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _abrirForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Nova manutenção'),
                        ),
                      ],
                    ),
                  );
                }

                final manutencoes = _filtrar(todas);
                if (manutencoes.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum resultado para "${_buscaController.text}"',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: manutencoes.length,
                  itemBuilder: (_, i) {
                    final manutencao = manutencoes[i];
                    final cor = _corEstado(manutencao.estadoOperacional);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cor,
                          child: const Icon(Icons.build, color: Colors.white),
                        ),
                        title: Text(
                          'Bike #${manutencao.bikeId} - Tipo #${manutencao.tipoManutencaoId}',
                        ),
                        subtitle: Text(
                          '${_fmt.format(manutencao.dataSolicitacao)} - '
                          '${manutencao.estadoOperacional.rotulo}\n'
                          '${manutencao.descricao}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        onTap: () => _abrirForm(manutencao),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: CoresApp.alerta),
                              onPressed: () => _abrirForm(manutencao),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: CoresApp.erro),
                              onPressed: () => _excluir(manutencao),
                              tooltip: 'Cancelar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
