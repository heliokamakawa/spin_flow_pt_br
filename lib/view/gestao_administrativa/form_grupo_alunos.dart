import 'package:flutter/material.dart';
import 'package:spin_flow/view/componentes/cores_app.dart';
import 'package:spin_flow/controller/controlador_grupo_alunos.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/domain/dominio/dominio_grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/grupo_alunos.dart';
import 'package:spin_flow/domain/modelo/aluno.dart';
import 'package:spin_flow/view/componentes/acao_sair_app_bar.dart';
import 'package:spin_flow/view/componentes/logo_spin_flow.dart';
import 'package:spin_flow/view/componentes/campo_ativo.dart';
import 'package:spin_flow/view/componentes/campo_busca_multipla.dart';

class FormGrupoAlunos extends StatefulWidget {
  final GrupoAlunos? grupo;

  const FormGrupoAlunos({super.key, this.grupo});

  @override
  State<FormGrupoAlunos> createState() => _FormGrupoAlunosState();
}

class _FormGrupoAlunosState extends State<FormGrupoAlunos> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = ControladorGrupoAlunos();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  List<Aluno> _alunosDisponiveis = [];
  List<Aluno> _alunosSelecionados = [];
  bool _carregando = true;
  bool _salvando = false;
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    final grupo = widget.grupo;
    if (grupo != null) {
      _nomeController.text = grupo.nome;
      _descricaoController.text = grupo.descricao;
      _alunosSelecionados = List<Aluno>.from(grupo.alunos);
      _ativo = grupo.ativo;
    }
    _carregarAlunos();
  }

  Future<void> _carregarAlunos() async {
    final alunos = await _controlador.listarAlunos();
    if (!mounted) return;
    setState(() {
      _alunosDisponiveis = _mesclarAlunos(alunos, _alunosSelecionados);
      _carregando = false;
    });
  }

  List<Aluno> _mesclarAlunos(
    List<Aluno> disponiveis,
    List<Aluno> selecionados,
  ) {
    final porId = <int, Aluno>{};
    for (final aluno in [...disponiveis, ...selecionados]) {
      final id = aluno.id;
      if (id != null) porId[id] = aluno;
    }
    final lista = porId.values.toList();
    lista.sort((a, b) => a.nome.compareTo(b.nome));
    return lista;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final grupo = GrupoAlunos(
      id: widget.grupo?.id,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      alunos: _alunosSelecionados,
      ativo: _ativo,
    );

    final resultado = await _controlador.salvar(DominioGrupoAlunos(grupo));
    if (!mounted) return;
    setState(() => _salvando = false);

    if (!resultado.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensagemErro!),
          backgroundColor: CoresApp.erro,
        ),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const TituloAppBarSpinFlow(),
        actions: const [AcaoSairAppBar()],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCampoNome(),
                  const SizedBox(height: 16),
                  _buildCampoDescricao(),
                  const SizedBox(height: 16),
                  CampoAtivo(
                    valor: _ativo,
                    aoAlterar: (valor) => setState(() => _ativo = valor),
                  ),
                  const SizedBox(height: 16),
                  _buildSelecaoAlunos(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tema.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _salvando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCampoNome() {
    return TextFormField(
      controller: _nomeController,
      decoration: const InputDecoration(
        labelText: 'Nome do grupo *',
        hintText: 'Grupo Frequencia Alta',
      ),
      validator: (valor) =>
          (valor == null || valor.trim().isEmpty) ? Erro.obrigatorio : null,
    );
  }

  Widget _buildCampoDescricao() {
    return TextFormField(
      controller: _descricaoController,
      minLines: 2,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Descricao',
        hintText: 'Alunos com alta presenca semanal',
      ),
    );
  }

  Widget _buildSelecaoAlunos() {
    return FormField<List<Aluno>>(
      initialValue: _alunosSelecionados,
      validator: (lista) => (lista == null || lista.isEmpty)
          ? 'Selecione pelo menos um aluno.'
          : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Alunos do grupo *',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: state.hasError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
              InkWell(
                onTap: _carregarAlunos,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 14, color: Theme.of(context).hintColor),
                      const SizedBox(width: 4),
                      Text(
                        'Recarregar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CampoBuscaMultipla<Aluno>(
            opcoes: _alunosDisponiveis,
            selecionados: _alunosSelecionados,
            getNome: (a) => a.nome,
            saoIguais: (a, b) => a.id == b.id,
            aoAlterar: (lista) {
              setState(() => _alunosSelecionados = lista);
              state.didChange(lista);
            },
            erroTexto: state.errorText,
            hintBusca: 'Buscar aluno...',
          ),
        ],
      ),
    );
  }
}
