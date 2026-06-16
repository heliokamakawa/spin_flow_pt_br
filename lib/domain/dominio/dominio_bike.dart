import 'package:spin_flow/domain/modelo/bike.dart';

class DominioBike {
  final Bike modelo;

  const DominioBike(this.modelo);

  String? validarRegras() {
    final hoje = DateTime.now();
    final amanha = DateTime(hoje.year, hoje.month, hoje.day + 1);
    if (modelo.dataCadastro.isAfter(amanha)) {
      return 'Data de cadastro não pode ser futura.';
    }
    return null;
  }

  String? validar() => validarRegras();
}
