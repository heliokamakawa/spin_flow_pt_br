import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spin_flow/infra/config/erro.dart';

class CampoData extends StatelessWidget {
  final String rotulo;
  final DateTime? valor;
  final bool obrigatorio;
  final void Function(DateTime) aoSelecionar;

  static final _formato = DateFormat('dd/MM/yyyy', 'pt_BR');

  const CampoData({
    super.key,
    required this.rotulo,
    required this.aoSelecionar,
    this.valor,
    this.obrigatorio = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: valor,
      validator: (v) => obrigatorio && v == null ? Erro.obrigatorio : null,
      builder: (state) {
        return InkWell(
          onTap: () async {
            final selecionada = await showDatePicker(
              context: context,
              initialDate: state.value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('pt', 'BR'),
            );
            if (selecionada != null) {
              state.didChange(selecionada);
              aoSelecionar(selecionada);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: rotulo,
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              state.value != null
                  ? _formato.format(state.value!)
                  : 'dd/mm/aaaa',
              style: TextStyle(
                color: state.value != null ? null : Colors.grey.shade500,
              ),
            ),
          ),
        );
      },
    );
  }
}
