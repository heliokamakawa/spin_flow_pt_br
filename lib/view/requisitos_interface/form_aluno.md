# Requisitos da Tela: Cadastro de Aluno (FormAluno)

> Arquivo de referência permanente. Criado em 2026-06-03.

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
| email | E-mail * | exemplo@email.com | e-mail | — |
| telefone | Telefone * | (11) 99999-9999 | numérico | `(XX) XXXXX-XXXX` |
| dataNascimento | Data de nascimento * | — | — | calendário PT-BR |
| genero | Gênero * | Selecione | — | dropdown |

### Opcionais

| Campo | Label | Hint |
|---|---|---|
| urlFoto | URL da foto | https://... |
| instagram | Instagram | @usuario |
| facebook | Facebook | Nome de perfil |
| tiktok | TikTok | @usuario |
| observacoes | Observações | Perfil de uso, preferências... |

---

## Campo Telefone — máscara

- Formato exibido: `(XX) XXXXX-XXXX` (celular) ou `(XX) XXXX-XXXX` (fixo)
- `TextInputFormatter` aplicado à medida que o usuário digita
- Teclado: `TextInputType.phone`
- Valor armazenado no banco: já formatado (ex.: `(11) 99999-1101`)

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
- **E-mail**: obrigatório + formato válido (`@`)
- **Telefone**: obrigatório + mínimo 10 dígitos após remover formatação
- **Data de nascimento**: obrigatória
- **Gênero**: obrigatório

A validação é disparada pelo `_formKey.currentState!.validate()` antes de salvar.
Erros exibidos abaixo de cada campo (`errorText`).

Validações de negócio (formato de telefone, e-mail) vivem em `Aluno.validar()`
e são invocadas pelo domínio ao salvar.

---

## Layout

- `ListView` com `padding: EdgeInsets.all(16)` — scrollável, inclusive com teclado aberto
- Campos obrigatórios com `*` no label
- `Switch` para campo `ativo`
- Botão **Salvar** em largura total ao final

---

## Estados

| Estado | Comportamento |
|---|---|
| Novo aluno | Todos os campos em branco; `_ativo = true` |
| Edição | Campos pré-preenchidos com dados do aluno |
| Erro de validação | Mensagem abaixo do campo, foco no primeiro inválido |
| Erro ao salvar | SnackBar com mensagem de erro |
| Sucesso | `Navigator.pop()` — volta à lista |

---

## Observações

- O formulário não exibe `AppBar` própria — usa a `AppBar` com `TituloAppBarSpinFlow` e `AcaoSairAppBar`
- Campos de redes sociais e observações são completamente opcionais e não têm validação de formato
