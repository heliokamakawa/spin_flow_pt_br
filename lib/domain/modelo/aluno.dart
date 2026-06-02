class Aluno {
  final int? id;
  final String nome;
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
    required this.email,
    required this.dataNascimento,
    required this.genero,
    required this.telefone,
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
    if (nome.trim().isEmpty) return 'Nome obrigatório';
    if (email.trim().isEmpty) return 'E-mail obrigatório';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'E-mail inválido';
    }
    if (telefone.trim().isEmpty) return 'Telefone obrigatório';
    if (dataNascimento == null) return 'Data de nascimento obrigatória';
    if (genero.trim().isEmpty) return 'Gênero obrigatório';
    return null;
  }
}
