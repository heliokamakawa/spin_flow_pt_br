import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParticipanteInstagram {
  final String nome;
  final String instagram;
  const ParticipanteInstagram({required this.nome, required this.instagram});
}

class PainelInstagram extends StatefulWidget {
  final List<ParticipanteInstagram> participantes;

  const PainelInstagram({super.key, required this.participantes});

  @override
  State<PainelInstagram> createState() => _PainelInstagramState();
}

class _PainelInstagramState extends State<PainelInstagram> {
  late List<ParticipanteInstagram> _selecionados;

  @override
  void initState() {
    super.initState();
    _selecionados = widget.participantes
        .where((p) => p.instagram.trim().isNotEmpty)
        .toList();
  }

  String _handle(ParticipanteInstagram p) {
    final ig = p.instagram.trim();
    return ig.startsWith('@') ? ig : '@$ig';
  }

  String get _marcacoes => _selecionados.map(_handle).join(' ');

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _marcacoes));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marcações copiadas!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semInstagram = widget.participantes
        .where((p) => p.instagram.trim().isEmpty)
        .length;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alternate_email),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Marcações para o Instagram',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selecionados.isEmpty)
            const Text(
              'Nenhum aluno com @Instagram cadastrado.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selecionados.map((p) {
                return Chip(
                  label: Text(_handle(p), style: const TextStyle(fontSize: 13)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _selecionados.remove(p)),
                );
              }).toList(),
            ),
          if (semInstagram > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$semInstagram aluno(s) sem Instagram cadastrado.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          if (_selecionados.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copiar marcações'),
                onPressed: _copiar,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
