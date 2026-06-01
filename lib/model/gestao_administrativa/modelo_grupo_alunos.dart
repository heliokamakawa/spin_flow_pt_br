import 'package:spin_flow/model/modelo/modelo_aluno.dart';

class ModeloGrupoAlunos {
  final int? id;
  final String nome;
  final String descricao;
  final List<ModeloAluno> alunos;
  final bool ativo;

  const ModeloGrupoAlunos({
    this.id,
    required this.nome,
    required this.descricao,
    required this.alunos,
    this.ativo = true,
  });

  String? validar() {
    if (nome.trim().isEmpty) return 'Nome do grupo é obrigatório.';
    if (alunos.where((aluno) => aluno.id != null).isEmpty) {
      return 'Selecione pelo menos um aluno.';
    }
    return null;
  }
}
