# Requisitos da Tela: Cadastro de Aluno (FormAluno)

> Arquivo de referência permanente. Criado em 2026-06-03. Atualizado em 2026-06-15.

---

## Descrição geral

Formulário de cadastro e edição de aluno. Acessado a partir da lista de alunos
no dashboard da professora. Ao salvar com sucesso, retorna à tela anterior.

---

## Campos

### Obrigatórios

| Campo | Label | Hint | Teclado | Máscara |
|---|---|---|---|---|
| nome | Nome * | Nome completo | texto | — |
| cpf | CPF * | 000.000.000-00 | numérico | `XXX.XXX.XXX-XX` |
| email | E-mail * | exemplo@email.com | e-mail | — |
| dataNascimento | Data de nascimento * | — | — | calendário PT-BR |
| genero | Gênero * | Selecione | — | dropdown |

### Opcionais

| Campo | Label | Hint |
|---|---|---|
| telefone | Telefone | (11) 99999-9999 |
| urlFoto | URL da foto | https://... |
| instagram | Instagram | @usuario |
| facebook | Facebook | Nome de perfil |
| tiktok | TikTok | @usuario |
| observacoes | Observações | Perfil de uso, preferências... |

---

## Campo CPF — máscara

- Formato exibido: `XXX.XXX.XXX-XX`
- `TextInputFormatter` aplicado à medida que o usuário digita
- Teclado: `TextInputType.number`
- Valor armazenado no banco: somente dígitos, 11 caracteres (ex.: `52998224725`)

## Campo Telefone — máscara

- Formato exibido: `(XX) XXXXX-XXXX` (celular) ou `(XX) XXXX-XXXX` (fixo)
- `TextInputFormatter` aplicado à medida que o usuário digita
- Teclado: `TextInputType.phone`
- Campo opcional — sem preenchimento, nenhuma validação é realizada

## Campo Data de nascimento — calendário

- Campo read-only com ícone de calendário (`Icons.calendar_today`)
- Ao tocar abre `showDatePicker` com locale `pt_BR`
- Exibição: `DD/MM/AAAA`
- Limites: `firstDate = 1900-01-01`, `lastDate = hoje`

## Campo Gênero — dropdown

| Valor | Label |
|---|---|
| `masculino` | Masculino |
| `feminino` | Feminino |
| `outro` | Outro |

---

## Validação inline (por campo)

- **Nome**: obrigatório
- **CPF**: obrigatório + 11 dígitos + dígitos verificadores válidos (`Aluno._cpfValido`)
- **E-mail**: obrigatório + formato válido (`@`)
- **Data de nascimento**: obrigatória + não pode ser futura
- **Gênero**: obrigatório (masculino / feminino / outro)
- **Telefone** (opcional): se preenchido, mínimo 10 dígitos após remover formatação
- **URL da foto** (opcional): se preenchida, deve ser URL válida (`http://` ou `https://`)

A validação de formato de CPF vive em `Aluno._cpfValido` (método estático privado no modelo).  
A validação de URL vive em `Aluno._urlValida` (método estático privado no modelo).  
A validação inline de formulário (campo a campo) é disparada pelo `_formKey.currentState!.validate()`.

---

## Validação de unicidade (no controlador)

Executada em `ControladorAluno.salvar` antes de persistir:

- **CPF**: `RepositorioAluno.buscarPorCpf` — busca todos os alunos (ativos e inativos).
  Se encontrado e `id != dominio.modelo.id`, retorna erro.
- **E-mail**: `RepositorioAluno.buscarPorEmail` — busca alunos ativos.
  Se encontrado e `id != dominio.modelo.id`, retorna erro.
- Exceções de constraint `UNIQUE` do banco também são capturadas como fallback.

Mensagens de erro exibidas em SnackBar com `CoresApp.erro`.

---

## Layout

- `ListView` com `padding: EdgeInsets.all(16)` — scrollável, inclusive com teclado aberto
- Seção obrigatória: nome, CPF, e-mail, data de nascimento, gênero
- Seção opcional: telefone, URL da foto, instagram, facebook, tiktok, observações
- `Switch` para campo `ativo`
- Botão **Salvar** em largura total ao final

---

## Estados

| Estado | Comportamento |
|---|---|
| Novo aluno | Todos os campos em branco; `_ativo = true` |
| Edição | Campos pré-preenchidos com dados do aluno; CPF exibido com máscara `XXX.XXX.XXX-XX` |
| Erro de validação | Mensagem abaixo do campo, foco no primeiro inválido |
| Erro ao salvar | SnackBar com mensagem de erro |
| Sucesso | `Navigator.pop()` — volta à lista |

---

## Observações

- O formulário não exibe `AppBar` própria — usa a `AppBar` com `TituloAppBarSpinFlow` e `AcaoSairAppBar`
- CPF é salvo como 11 dígitos sem formatação; exibido com máscara ao editar
- Campos de redes sociais e observações são completamente opcionais e não têm validação de formato
