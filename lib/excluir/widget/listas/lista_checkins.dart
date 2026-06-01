import 'package:flutter/material.dart';
import 'package:spin_flow/core/tema/cores_app.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_checkin.dart';
import 'package:spin_flow/excluir/dto/dto_checkin.dart';

import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';

class ListaCheckins extends StatefulWidget {
  const ListaCheckins({super.key});

  @override
  State<ListaCheckins> createState() => _ListaCheckinsState();
}

class _ListaCheckinsState extends State<ListaCheckins> {
  final DAOCheckin _dao = DAOCheckin();
  List<DTOCheckin> _itens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final itens = await _dao.buscarTodos();
      itens.sort((a, b) => b.data.compareTo(a.data));
      setState(() {
        _itens = itens;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar check-ins: $e'),
            backgroundColor: CoresApp.erro,
          ),
        );
      }
    }
  }

  Future<void> _cancelarCheckin(DTOCheckin item) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Check-in'),
        content: Text(
          'Deseja cancelar o check-in de "${item.aluno.nome}" '
          'na turma "${item.turma.nome}" em ${_formatarData(item.data)}?\n\n'
          'A posiÃ§Ã£o serÃ¡ liberada para nova reserva.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('NÃ£o'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: CoresApp.erro),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
    if (confirmacao != true) return;
    try {
      await _dao.cancelar(item.id!);
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in cancelado com sucesso!'),
            backgroundColor: CoresApp.sucesso,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar: $e'),
            backgroundColor: CoresApp.erro,
          ),
        );
      }
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final ativos = _itens.where((c) => c.ativo).toList();
    final cancelados = _itens.where((c) => !c.ativo).toList();

    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _itens.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum check-in registrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                if (ativos.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Check-ins Ativos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...ativos.map((item) => _itemCheckin(item, hojeSemHora)),
                ],
                if (cancelados.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Check-ins Cancelados (HistÃ³rico)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...cancelados.map((item) => _itemCheckin(item, hojeSemHora)),
                ],
              ],
            ),
    );
  }

  Widget _itemCheckin(DTOCheckin item, DateTime hojeSemHora) {
    final dataSemHora = DateTime(
      item.data.year,
      item.data.month,
      item.data.day,
    );
    final ehFuturo =
        dataSemHora.isAfter(hojeSemHora) ||
        dataSemHora.isAtSameMomentAs(hojeSemHora);
    final statusTexto = !item.ativo
        ? 'Cancelado'
        : ehFuturo
        ? 'Agendado'
        : 'ConcluÃ­do';
    final statusCor = !item.ativo
        ? Colors.grey
        : ehFuturo
        ? CoresApp.info
        : CoresApp.sucesso;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusCor,
          child: Icon(
            !item.ativo
                ? Icons.cancel
                : (ehFuturo ? Icons.schedule : Icons.check_circle),
            color: Colors.white,
          ),
        ),
        title: Text('${item.aluno.nome} â€” ${item.turma.nome}'),
        subtitle: Text(
          'Data: ${_formatarData(item.data)}\n'
          'PosiÃ§Ã£o: Fila ${item.fila + 1}, Coluna ${item.coluna + 1}\n'
          'Status: $statusTexto',
        ),
        isThreeLine: true,
        trailing: item.ativo && ehFuturo
            ? IconButton(
                icon: const Icon(Icons.cancel, color: CoresApp.erro),
                onPressed: () => _cancelarCheckin(item),
                tooltip: 'Cancelar check-in',
              )
            : null,
      ),
    );
  }
}
