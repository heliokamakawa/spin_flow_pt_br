# Requisitos da Tela: Cadastro de Turma (FormTurma)

> Arquivo de referência permanente. Criado em 2026-06-03.

---

## Descrição geral

Formulário de cadastro e edição de turma. Acessado a partir da lista de turmas
no dashboard da professora. Ao salvar com sucesso, retorna à lista (pop com `true`).

---

## Campos

### Obrigatórios

| Campo | Label | Hint | Teclado | Observações |
|---|---|---|---|---|
| nome | Identificação * | Spinning Avançado - 18:00 | texto | — |
| horarioInicio | Horário de início * | 18:00 | datetime | formato `HH:mm` |
| duracaoMinutos | Duração (minutos) * | 50 | numérico | somente dígitos |
| salaId | Sala * | Selecione uma sala | — | dropdown |
| diasSemana | Dias da semana * | — | — | FilterChip multi-seleção |

### Opcionais

| Campo | Label | Hint |
|---|---|---|
| professoraId | Professora | Selecione uma professora |
| ativo | (switch) | via CampoAtivo |

---

## Validações inline

- **Identificação**: obrigatório
- **Horário de início**: obrigatório + formato `HH:mm` + hora 0–23 + minuto 0–59
- **Duração**: obrigatório + entre **1 e 100 minutos**
- **Sala**: obrigatório
- **Dias da semana**: pelo menos um dia selecionado

A regra de duração (1–100 min) é validada tanto no `Turma.validar()` quanto no validator inline da view.

---

## Valores padrão (nova turma)

| Campo | Padrão |
|---|---|
| horarioInicio | `18:00` |
| duracaoMinutos | `50` |
| diasSemana | `[segunda]` |
| ativo | `true` |

---

## Layout

- `ListView` com `padding: EdgeInsets.all(16)` — scrollável
- Campos obrigatórios com `*` no label
- Botão **Salvar** em largura total; exibe `CircularProgressIndicator` durante salvamento
- `AppBar` com `TituloAppBarSpinFlow` e `AcaoSairAppBar`

---

## Estados

| Estado | Comportamento |
|---|---|
| Carregando | `CircularProgressIndicator` central |
| Novo | Campos em branco com padrões acima |
| Edição | Campos pré-preenchidos com dados da turma |
| Erro de validação | Mensagem abaixo do campo |
| Erro ao salvar | SnackBar com mensagem de erro |
| Sucesso | `Navigator.pop(true)` — volta à lista |
