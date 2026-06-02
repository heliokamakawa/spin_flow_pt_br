import 'package:flutter/material.dart';
import 'package:spin_flow/infra/tema/cores_app.dart';
import 'package:get_it/get_it.dart';
import 'package:spin_flow/controller/controlador_recuperacao_senha.dart';
import 'package:spin_flow/infra/config/erro.dart';
import 'package:spin_flow/infra/navegacao/rotas.dart';
import 'package:spin_flow/domain/modelo/usuario.dart';
import 'package:spin_flow/domain/modelo/validador_cpf.dart';
import 'package:spin_flow/view/componentes/campo_senha.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _controlador = GetIt.I<ControladorRecuperacaoSenha>();

  int _etapa = 0;
  bool _carregando = false;
  String? _erro;
  Usuario? _usuario;

  @override
  void dispose() {
    _emailController.dispose();
    _cpfController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _avancar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });

    switch (_etapa) {
      case 0:
        final resultado = await _controlador.verificarEmail(
          _emailController.text,
        );
        if (!mounted) return;
        if (!resultado.sucesso) {
          setState(() {
            _carregando = false;
            _erro = resultado.mensagemErro;
          });
          return;
        }
        _usuario = resultado.usuario;

      case 1:
        final resultado = _controlador.verificarCpf(
          _usuario!,
          _cpfController.text,
        );
        if (!resultado.sucesso) {
          setState(() {
            _carregando = false;
            _erro = resultado.mensagemErro;
          });
          return;
        }

      case 2:
        final resultado = await _controlador.redefinirSenha(
          _usuario!.id,
          _novaSenhaController.text,
          _confirmarSenhaController.text,
        );
        if (!mounted) return;
        if (!resultado.sucesso) {
          setState(() {
            _carregando = false;
            _erro = resultado.mensagemErro;
          });
          return;
        }
    }

    setState(() {
      _carregando = false;
      _etapa++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar senha'),
        backgroundColor: tema.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _etapa == 3
                  ? _buildConfirmacao(context)
                  : _buildFormulario(tema),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormulario(ThemeData tema) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIndicadorEtapas(tema),
              const SizedBox(height: 24),
              _buildCabecalhoEtapa(),
              const SizedBox(height: 20),
              _buildCamposEtapa(),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erro!,
                  style: TextStyle(color: CoresApp.erro),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _avancar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tema.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _textoBotao(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicadorEtapas(ThemeData tema) {
    return Row(
      children: List.generate(3, (i) {
        final ativa = i <= _etapa;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: ativa ? tema.primaryColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCabecalhoEtapa() {
    final (icone, titulo, descricao) = switch (_etapa) {
      0 => (
        Icons.email_outlined,
        'Informe seu e-mail',
        'Digite o e-mail cadastrado para iniciar a recuperação.',
      ),
      1 => (
        Icons.badge_outlined,
        'Confirme sua identidade',
        'Informe o CPF vinculado à sua conta.',
      ),
      _ => (Icons.lock_reset, 'Nova senha', 'Defina sua nova senha de acesso.'),
    };

    return Column(
      children: [
        Icon(icone, size: 48, color: Colors.grey.shade600),
        const SizedBox(height: 12),
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          descricao,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCamposEtapa() {
    return switch (_etapa) {
      0 => TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'E-mail',
          hintText: 'nome@provedora.com',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? Erro.obrigatorio : null,
        autofillHints: const [AutofillHints.email],
      ),
      1 => TextFormField(
        controller: _cpfController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'CPF',
          hintText: '000.000.000-00',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
        validator: (v) {
          final texto = v?.trim() ?? '';
          if (texto.isEmpty) return Erro.obrigatorio;
          if (!ValidadorCpf.valido(texto)) return 'Informe um CPF válido.';
          return null;
        },
      ),
      _ => Column(
        children: [
          CampoSenha(
            controle: _novaSenhaController,
            rotulo: 'Nova senha',
            dica: 'Mínimo 4 caracteres',
            mensagemErro: Erro.obrigatorio,
            validador: (v) => (v == null || v.length < 4)
                ? 'A senha deve ter pelo menos 4 caracteres.'
                : null,
          ),
          const SizedBox(height: 16),
          CampoSenha(
            controle: _confirmarSenhaController,
            rotulo: 'Confirmar senha',
            dica: 'Repita a nova senha',
            mensagemErro: Erro.obrigatorio,
          ),
        ],
      ),
    };
  }

  Widget _buildConfirmacao(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 72,
          color: CoresApp.sucesso,
        ),
        const SizedBox(height: 16),
        const Text(
          'Senha redefinida com sucesso!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Você já pode fazer login com a nova senha.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, Rotas.login),
            icon: const Icon(Icons.login),
            label: const Text('Ir para o login'),
          ),
        ),
      ],
    );
  }

  String _textoBotao() => switch (_etapa) {
    0 => 'Verificar e-mail',
    1 => 'Confirmar identidade',
    _ => 'Redefinir senha',
  };
}
