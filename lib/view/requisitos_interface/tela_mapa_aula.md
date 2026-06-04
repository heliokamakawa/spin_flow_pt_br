# Requisitos da Tela: Mapa de Aula (TelaMapeamentoAula)

> Arquivo de referência permanente. Criado em 2026-06-03.

---

## Descrição geral

Tela da professora que exibe o mapa da sala com o estado atual de cada bike para
uma turma específica do dia. Permite cancelar reservas, registrar e resolver
manutenções, e gerar marcações de Instagram dos alunos presentes.

---

## Entrada

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `turmaId` | `int` | ID da turma selecionada |
| `nomeTurma` | `String` | Nome exibido na tela |

---

## Mapa de bikes

- Exibido como `GridView` com `crossAxisCount = sala.numeroColunas`
- Cada célula representa uma posição (fila × coluna)

### Estados de célula

| Estado | Cor | Label | Ação ao tocar |
|---|---|---|---|
| Professora | `bikeProfessora` | "Profa" | — (sem ação) |
| Sem bike | cinza fraco | "—" | — (sem ação) |
| Manutenção | `bikeManutencao` | "Manut" | Abre diálogo para resolver manutenção |
| Reservada (check-in) | `bikeOcupada` | nome do aluno | Abre diálogo para cancelar reserva |
| Livre | `bikeLivre` | nome da bike | Abre diálogo para registrar manutenção |

### Legenda

Exibida acima do grid: Professora · Reservada · Livre · Manutenção.

---

## Diálogos

### Cancelar reserva
- Título: nome do aluno
- Mensagem: "Cancelar reserva?"
- Ações: Não / Cancelar

### Registrar manutenção
- Título: nome da bike
- Campos: dropdown de tipo + campo de motivo (textarea)
- Ações: Não / Registrar

### Resolver manutenção
- Título: nome da bike
- Mensagem: "Marcar como boa?"
- Ações: Não / Sim

---

## Painel de Marcações Instagram

Ativado por um `IconButton` (`Icons.alternate_email`) no AppBar.
**Visível apenas quando há check-ins ativos na turma.**

Ao tocar, abre `showModalBottomSheet` com:

1. **Chips removíveis** — um por aluno com `instagramAluno` preenchido, no formato `@handle`.
   - Cada chip tem botão X para remover da lista
   - Alunos sem Instagram cadastrado são ignorados por padrão
   - Se nenhum aluno tem Instagram: exibe mensagem informativa
2. **Nota informativa** — "N aluno(s) sem Instagram cadastrado." (quando aplicável)
3. **Botão "Copiar marcações"** — copia todos os `@handles` restantes, separados por espaço, para a área de transferência via `Clipboard.setData`
   - Exibe SnackBar "Marcações copiadas!" após cópia
   - Visível somente se ainda houver ao menos um chip

### Normalização do handle
- Se o valor salvo já começa com `@`: usa como está
- Se não começa com `@`: adiciona o prefixo antes de exibir/copiar

---

## AppBar

- Título: `TituloAppBarSpinFlow`
- Ações: `[IconButton Instagram (condicional), AcaoSairAppBar]`

---

## Estados da tela

| Estado | Comportamento |
|---|---|
| Carregando | `CircularProgressIndicator` central |
| Erro | Mensagem de erro centralizada |
| Dados carregados | Legenda + GridView |
