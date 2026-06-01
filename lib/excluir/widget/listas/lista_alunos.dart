import 'package:flutter/material.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_aluno.dart';
import 'package:spin_flow/excluir/dto/dto_aluno.dart';
import 'package:spin_flow/excluir/configuracoes/rotas.dart';
import 'package:spin_flow/excluir/widget/componentes/lista_padrao.dart';

class ListaAlunos extends StatelessWidget {
  const ListaAlunos({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = DAOAluno();
    return ListaPadrao<DTOAluno>(
      titulo: 'Alunos',
      icone: Icons.person,
      mensagemVazia: 'Nenhum aluno cadastrado',
      rotaCadastro: Rotas.cadastroAluno,
      carregar: dao.buscarTodos,
      excluir: dao.excluir,
      ativo: (a) => a.ativo,
      detalhes: (a) =>
          'Email: ${a.email}\nTelefone: ${a.telefone}\nNascimento: ${a.dataNascimento.toString().split(' ')[0]}',
    );
  }
}
