# Requisitos da Tela: Tipo de Manutenção (FormTipoManutencao / ListaTipoManutencao)

> Arquivo de referência permanente. Criado em 2026-06-15.

---

## Descrição geral

Permite cadastrar, consultar, atualizar, inativar e reativar tipos de manutenção.
Acessado a partir da tela de Gestão Administrativa (item "Tipos de Manutenção").

---

## Campos do formulário

### Obrigatórios

| Campo | Label | Hint |
|---|---|---|
| nome | Nome * | Ex.: Pedal quebrado |

### Opcionais

| Campo | Label | Hint |
|---|---|---|
| descricao | Descrição | Detalhes sobre este tipo de manutenção |
| ativa | (Switch) Ativo | — |

---

## Validação

- **Nome**: obrigatório (mensagem: "Este campo é obrigatório.")
- **Descrição**: sem validação de formato

A validação vive em `TipoManutencao.validar()` e é chamada por `DominioTipoManutencao.validar()`.

---

## Comportamento do formulário

| Situação | Comportamento |
|---|---|
| Novo cadastro | Campos em branco; `ativa = true` |
| Edição | Campos pré-preenchidos; `ativa` reflete estado atual |
| Erro de validação | SnackBar com mensagem de erro |
| Sucesso | `Navigator.pop(true)` — volta à lista e recarrega |

A **reativação** ocorre via edição: filtrar por "Inativos" na lista → editar o registro → ativar o Switch → Salvar.

---

## Lista (ListaTipoManutencao)

- Exibe todos os tipos (ativos e inativos), ordenados por nome
- Filtro de status: chips "Ativos" / "Inativos" (padrão: Ativos); clicar no chip selecionado remove o filtro
- Campo de busca por nome e descrição
- FAB "+" para novo cadastro

### Card de cada tipo

| Elemento | Descrição |
|---|---|
| Avatar | Verde (ativo) ou cinza (inativo) com ícone `build_circle` |
| Título | `nome` |
| Subtítulo | `descricao` truncada (1 linha); se vazio e inativo, exibe "Inativo" |
| Botão editar | Ícone lápis — abre `FormTipoManutencao` preenchido |
| Botão inativar | Ícone `block` — visível apenas para registros ativos; pede confirmação |

### Inativar

- Confirmação via `AlertDialog` antes de chamar `ControladorTipoManutencao.excluir`
- Soft delete: `ativa = 0` no banco
- Botão "Inativar" oculto para registros já inativos (edição reativa via form)

---

## Reativar

1. Filtrar a lista por "Inativos"
2. Tocar no card ou no ícone de edição
3. No formulário, ativar o switch
4. Salvar → registro volta a `ativa = true`

---

## Observações

- `TipoManutencao` é referenciado em `Manutencao` (FK `tipo_manutencao_id`) e no formulário de manutenção como dropdown
- Inativar um tipo não remove manutenções existentes vinculadas a ele
