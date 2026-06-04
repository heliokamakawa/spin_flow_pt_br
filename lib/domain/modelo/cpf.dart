class Cpf {
  static bool valido(String cpf) {
    final normalizado = cpf.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^\d{11}$').hasMatch(normalizado);
  }

  static String normalizar(String cpf) => cpf.replaceAll(RegExp(r'\D'), '');
}
