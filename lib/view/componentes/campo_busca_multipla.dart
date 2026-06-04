import 'package:flutter/material.dart';
import 'package:spin_flow/infra/config/cores_app.dart';

class CampoBuscaMultipla<T> extends StatefulWidget {
  final List<T> opcoes;
  final List<T> selecionados;
  final String Function(T) getNome;
  final bool Function(T, T) saoIguais;
  final void Function(List<T>) aoAlterar;
  final String hintBusca;
  final String? erroTexto;

  /// Quando fornecido, exibe "Criar '[texto]'" no dropdown caso não haja
  /// correspondência exata. O callback deve retornar o novo item ou null.
  final T? Function(String texto)? criarNovo;

  const CampoBuscaMultipla({
    super.key,
    required this.opcoes,
    required this.selecionados,
    required this.getNome,
    required this.saoIguais,
    required this.aoAlterar,
    this.hintBusca = 'Digite para buscar...',
    this.erroTexto,
    this.criarNovo,
  });

  @override
  State<CampoBuscaMultipla<T>> createState() => _CampoBuscaMultiplaState<T>();
}

class _CampoBuscaMultiplaState<T> extends State<CampoBuscaMultipla<T>> {
  final _buscaController = TextEditingController();
  List<T> _sugestoes = [];
  bool _mostraSugestoes = false;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrar(String texto) {
    setState(() {
      if (texto.isEmpty) {
        _sugestoes = [];
        _mostraSugestoes = false;
        return;
      }
      _sugestoes = widget.opcoes.where((item) {
        final jaSelecionado = widget.selecionados.any(
          (s) => widget.saoIguais(s, item),
        );
        return !jaSelecionado &&
            widget.getNome(item).toLowerCase().contains(texto.toLowerCase());
      }).toList();
      _mostraSugestoes = _sugestoes.isNotEmpty || widget.criarNovo != null;
    });
  }

  bool _podeCriar() {
    if (widget.criarNovo == null) return false;
    final texto = _buscaController.text.trim();
    if (texto.isEmpty) return false;
    return !_sugestoes.any(
      (s) => widget.getNome(s).toLowerCase() == texto.toLowerCase(),
    );
  }

  void _adicionar(T item) {
    widget.aoAlterar([...widget.selecionados, item]);
    _buscaController.clear();
    setState(() {
      _sugestoes = [];
      _mostraSugestoes = false;
    });
  }

  void _criarENovo() {
    final texto = _buscaController.text.trim();
    if (texto.isEmpty || widget.criarNovo == null) return;
    final novo = widget.criarNovo!(texto);
    if (novo != null) _adicionar(novo);
  }

  void _remover(T item) {
    widget.aoAlterar(
      widget.selecionados.where((s) => !widget.saoIguais(s, item)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final corErro = Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _buscaController,
          decoration: InputDecoration(
            hintText: widget.hintBusca,
            prefixIcon: const Icon(Icons.search),
            isDense: true,
          ),
          onChanged: _filtrar,
        ),
        if (_mostraSugestoes)
          Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  ..._sugestoes.map(
                    (item) => ListTile(
                      dense: true,
                      title: Text(widget.getNome(item)),
                      onTap: () => _adicionar(item),
                    ),
                  ),
                  if (_podeCriar())
                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.add_circle_outline,
                        size: 18,
                        color: CoresApp.sucesso,
                      ),
                      title: Text('Criar "${_buscaController.text.trim()}"'),
                      onTap: _criarENovo,
                    ),
                ],
              ),
            ),
          ),
        if (widget.selecionados.isNotEmpty) ...[
          const Divider(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.selecionados.length,
              itemBuilder: (_, i) {
                final item = widget.selecionados[i];
                return ListTile(
                  dense: true,
                  title: Text(widget.getNome(item)),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: corErro, size: 18),
                    onPressed: () => _remover(item),
                    tooltip: 'Remover',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                );
              },
            ),
          ),
        ],
        if (widget.erroTexto != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              widget.erroTexto!,
              style: TextStyle(color: corErro, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
