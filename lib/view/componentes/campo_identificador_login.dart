import 'package:flutter/material.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/domain/modelo/cpf.dart';
import 'package:spin_flow/domain/modelo/email.dart';

class CampoIdentificadorLogin extends StatelessWidget {
  final TextEditingController? controle;
  final String rotulo;
  final String dica;
  final bool eObrigatorio;
  final String? Function(String?)? validador;
  final void Function(String)? aoAlterar;

  const CampoIdentificadorLogin({
    super.key,
    this.controle,
    this.rotulo = 'E-mail ou CPF',
    this.dica = 'E-mail ou CPF',
    this.eObrigatorio = true,
    this.validador,
    this.aoAlterar,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controle,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: dica,
        prefixIcon: const Icon(Icons.person_search),
      ),
      validator: (valor) => _validarCampo(valor),
      onChanged: aoAlterar,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
    );
  }

  String? _validarCampo(String? valor) {
    if (validador != null) {
      return validador!(valor);
    }

    final texto = valor?.trim() ?? '';
    if (eObrigatorio && texto.isEmpty) {
      return Erro.obrigatorio;
    }

    if (texto.isEmpty) return null;

    if (!Email.valido(texto) && !Cpf.valido(texto)) {
      return 'Informe um e-mail ou CPF valido.';
    }

    return null;
  }
}
