class Email {
  static final _regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool valido(String email) => _regex.hasMatch(email);
}
