import 'package:flutter/material.dart';
import 'package:spin_flow/infra/config/tema_app.dart';

class CampoAtivo extends StatelessWidget {
  final bool valor;
  final void Function(bool) aoAlterar;

  const CampoAtivo({super.key, required this.valor, required this.aoAlterar});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).extension<CoresSemanticasApp>()!;

    return Container(
      decoration: BoxDecoration(
        color: valor
            ? cores.sucessoSuave
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: valor ? cores.sucesso : cores.borda),
      ),
      child: CheckboxListTile(
        title: Text(
          'Ativo',
          style: TextStyle(
            color: valor ? cores.sucesso : cores.textoSuave,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: valor,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (v) => aoAlterar(v ?? valor),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
