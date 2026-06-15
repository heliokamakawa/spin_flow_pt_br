class Aluno {
  final int? id;
  final String nome;
  final String cpf;
  final String email;
  final DateTime? dataNascimento;
  final String genero;
  final String telefone;
  final String urlFoto;
  final String instagram;
  final String facebook;
  final String tiktok;
  final String observacoes;
  final bool ativo;

  Aluno({
    this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.dataNascimento,
    required this.genero,
    this.telefone = '',
    this.urlFoto = '',
    this.instagram = '',
    this.facebook = '',
    this.tiktok = '',
    this.observacoes = '',
    this.ativo = true,
  });

  Aluno copyWith({
    int? id,
    String? nome,
    String? cpf,
    String? email,
    DateTime? dataNascimento,
    String? genero,
    String? telefone,
    String? urlFoto,
    String? instagram,
    String? facebook,
    String? tiktok,
    String? observacoes,
    bool? ativo,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      genero: genero ?? this.genero,
      telefone: telefone ?? this.telefone,
      urlFoto: urlFoto ?? this.urlFoto,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      tiktok: tiktok ?? this.tiktok,
      observacoes: observacoes ?? this.observacoes,
      ativo: ativo ?? this.ativo,
    );
  }

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome obrigatório.';

    final digCpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (digCpf.isEmpty) return 'CPF obrigatório.';
    if (!_cpfValido(digCpf)) return 'CPF inválido.';

    if (email.trim().isEmpty) return 'E-mail obrigatório.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      return 'E-mail inválido.';
    }

    if (dataNascimento == null) return 'Data de nascimento obrigatória.';
    final hoje = DateTime.now();
    if (dataNascimento!.isAfter(DateTime(hoje.year, hoje.month, hoje.day))) {
      return 'Data de nascimento não pode ser futura.';
    }

    if (!['masculino', 'feminino', 'outro'].contains(genero)) {
      return 'Gênero obrigatório.';
    }

    if (telefone.trim().isNotEmpty) {
      final digTel = telefone.replaceAll(RegExp(r'\D'), '');
      if (digTel.length < 10 || digTel.length > 11) {
        return 'Telefone inválido — informe DDD + número.';
      }
    }

    if (urlFoto.trim().isNotEmpty && !_urlValida(urlFoto.trim())) {
      return 'URL da foto inválida — deve começar com http:// ou https://.';
    }

    return null;
  }

  static bool _cpfValido(String d) {
    if (d.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(d[i]) * (10 - i);
    }
    int r = 11 - soma % 11;
    if (r >= 10) r = 0;
    if (r != int.parse(d[9])) return false;
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(d[i]) * (11 - i);
    }
    r = 11 - soma % 11;
    if (r >= 10) r = 0;
    return r == int.parse(d[10]);
  }

  static bool _urlValida(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
