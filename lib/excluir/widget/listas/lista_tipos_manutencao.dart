import 'package:flutter/material.dart';
import 'package:spin_flow/excluir/banco/sqlite/dao/dao_tipo_manutencao.dart';
import 'package:spin_flow/excluir/dto/dto_tipo_manutencao.dart';
import 'package:spin_flow/excluir/configuracoes/rotas.dart';
import 'package:spin_flow/excluir/widget/componentes/lista_padrao.dart';

class ListaTiposManutencao extends StatelessWidget {
  const ListaTiposManutencao({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = DAOTipoManutencao();
    return ListaPadrao<DTOTipoManutencao>(
      titulo: 'Tipos de Manutenção',
      icone: Icons.build,
      mensagemVazia: 'Nenhum tipo de manutenção cadastrado',
      rotaCadastro: Rotas.cadastroTipoManutencao,
      carregar: dao.buscarTodos,
      excluir: dao.excluir,
      ativo: (t) => t.ativa,
      detalhes: (t) {
        final descricao = t.descricao?.isNotEmpty == true
            ? '${t.descricao}\n'
            : '';
        return '$descricao${t.ativa ? 'Ativo' : 'Inativo'}';
      },
    );
  }
}
