import 'package:spin_flow/model/modelo/modelo_aluno.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_aluno.dart';
import 'package:spin_flow/excluir/dto/dto_aluno.dart';

class ServicoAluno {
  final DAOAluno _daoAluno;
  ServicoAluno({DAOAluno? daoAluno}) : _daoAluno = daoAluno ?? DAOAluno();

  Future<void> salvar(ModeloAluno aluno) async {
    final dto = _toDto(aluno);
    await _daoAluno.salvar(dto);
  }

  Future<ModeloAluno?> buscarPorId(int id) async {
    final dto = await _daoAluno.buscarPorId(id);
    return dto == null ? null : _fromDto(dto);
  }

  Future<List<ModeloAluno>> buscarTodos() async {
    final lista = await _daoAluno.buscarTodos();
    return lista.map(_fromDto).toList();
  }

  Future<void> atualizar(ModeloAluno aluno) async {
    final dto = _toDto(aluno);
    await _daoAluno.salvar(dto); // Assume que salvar faz update se id existe
  }

  Future<void> remover(int id) async {
    final aluno = await buscarPorId(id);
    if (aluno != null) {
      await salvar(aluno.copyWith(ativo: false));
    }
  }

  // Conversão DTO <-> Modelo
  DTOAluno _toDto(ModeloAluno aluno) => DTOAluno(
    id: aluno.id,
    nome: aluno.nome,
    email: aluno.email,
    dataNascimento: aluno.dataNascimento!,
    genero: aluno.genero,
    telefone: aluno.telefone,
    urlFoto: aluno.urlFoto,
    instagram: aluno.instagram,
    facebook: aluno.facebook,
    tiktok: aluno.tiktok,
    observacoes: aluno.observacoes,
    ativo: aluno.ativo,
  );

  ModeloAluno _fromDto(DTOAluno dto) => ModeloAluno(
    id: dto.id,
    nome: dto.nome,
    email: dto.email,
    dataNascimento: dto.dataNascimento,
    genero: dto.genero,
    telefone: dto.telefone,
    urlFoto: dto.urlFoto,
    instagram: dto.instagram,
    facebook: dto.facebook,
    tiktok: dto.tiktok,
    observacoes: dto.observacoes,
    ativo: dto.ativo,
  );
}
