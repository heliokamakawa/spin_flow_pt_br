import 'package:flutter/material.dart';

String normalizarBusca(String s) => s
    .toLowerCase()
    .trim()
    .replaceAll(RegExp(r'[àáâãä]'), 'a')
    .replaceAll(RegExp(r'[èéêë]'), 'e')
    .replaceAll(RegExp(r'[ìíîï]'), 'i')
    .replaceAll(RegExp(r'[òóôõö]'), 'o')
    .replaceAll(RegExp(r'[ùúûü]'), 'u')
    .replaceAll('ç', 'c')
    .replaceAll('ñ', 'n');

// Retorna itens filtrados com prioridade: exato > começa com > contém.
// [campos] deve retornar todos os textos pesquisáveis do item.
List<T> filtrarComPrioridade<T>(
  List<T> itens,
  String termo,
  List<String> Function(T) campos,
) {
  if (termo.isEmpty) return itens;
  final t = normalizarBusca(termo);

  int nivel(T item) {
    int melhor = 3;
    for (final campo in campos(item)) {
      final s = normalizarBusca(campo);
      if (s == t) return 0;
      if (s.startsWith(t) && melhor > 1) melhor = 1;
      if (s.contains(t) && melhor > 2) melhor = 2;
    }
    return melhor;
  }

  return itens.where((e) => nivel(e) < 3).toList()
    ..sort((a, b) => nivel(a).compareTo(nivel(b)));
}

class CampoBusca extends StatelessWidget {
  final TextEditingController controlador;
  final String dica;

  const CampoBusca({
    super.key,
    required this.controlador,
    this.dica = 'Buscar...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: controlador,
        decoration: InputDecoration(
          hintText: dica,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controlador,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controlador.clear(),
                  )
                : const SizedBox.shrink(),
          ),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
