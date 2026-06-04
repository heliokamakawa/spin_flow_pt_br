class SessaoUsuario {
  static int? usuarioId;
  static int? alunoId;
  static int? professoraId;
  static String? nome;
  static String? email;
  static String? perfil;
  static DateTime? _ultimaAtividade;

  static const int _timeoutMinutos = 30;

  static bool get ehProfessora => (perfil ?? '').toLowerCase() == 'professora';
  static bool get ehAluno => (perfil ?? '').toLowerCase() == 'aluno';
  static bool get ativa => usuarioId != null;

  static bool get expirada {
    if (_ultimaAtividade == null || usuarioId == null) return false;
    return DateTime.now().difference(_ultimaAtividade!).inMinutes >=
        _timeoutMinutos;
  }

  static void registrarAtividade() {
    if (usuarioId != null) {
      _ultimaAtividade = DateTime.now();
    }
  }

  static void iniciar({
    required int id,
    required String nomeUsuario,
    required String emailUsuario,
    required String perfilUsuario,
    int? alunoId,
    int? professoraId,
  }) {
    usuarioId = id;
    nome = nomeUsuario;
    email = emailUsuario;
    perfil = perfilUsuario;
    SessaoUsuario.alunoId = alunoId;
    SessaoUsuario.professoraId = professoraId;
    _ultimaAtividade = DateTime.now();
  }

  static void encerrar() {
    usuarioId = null;
    alunoId = null;
    professoraId = null;
    nome = null;
    email = null;
    perfil = null;
    _ultimaAtividade = null;
  }
}
