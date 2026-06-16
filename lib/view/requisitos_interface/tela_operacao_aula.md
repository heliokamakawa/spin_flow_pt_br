# Requisitos da Tela: Lista de Turmas da Professora (TelaOperacaoAula)

> Arquivo de referência permanente para evitar re-especificação entre conversas.

---

## Descrição geral

Aba "Aulas" do dashboard da professora. Exibe as turmas agendadas para hoje em ordem de horário, com acesso ao mapa de aula e à fila de espera.

---

## Estados da tela

| Estado      | Exibição                                              |
|-------------|-------------------------------------------------------|
| Carregando  | `CircularProgressIndicator` centralizado              |
| Erro        | Mensagem + botão "Tentar novamente"                   |
| Lista vazia | Ícone `event_busy` + "Nenhuma turma agendada para hoje." |
| Lista normal| `ListView` com `RefreshIndicator`                     |

---

## Card de turma

### Seção principal (ListTile)

- **Título**: nome da turma (negrito)
- **Subtítulo**: horário · duração min, Sala: X, Dias: X
- **Leading**: `CircleAvatar` com ícone `fitness_center`
- **Trailing**: `chevron_right`
- **Ao tocar**: navega para `TelaMapeamentoAula`

### Seção fila de espera (abaixo do ListTile)

Exibida somente quando `totalNaFila > 0`:

- Separada por `Divider`
- Linha: ícone `people_outline` (alerta) + "Fila de espera · N pessoa(s)" + `chevron_right`
- Ao tocar: abre `ModalBottomSheet` com título, nome da turma e lista de nomes numerados
- Nomes carregados via `buscarNomesNaFila` com `FutureBuilder` (exibe indicador enquanto carrega)

---

## Painel inferior

Botão "Painel de Frequência" (largura total) → abre `TelaPainelFrequenciaProfessora`.

---

## Regras de negócio

- Turmas filtradas por dia da semana (hoje) e ativas, ordenadas por horário de início.
- `totalNaFila` é contado no repositório via `IDAOFilaEsperaCheckin.contarNaFila`.
- Nomes da fila são carregados via `ControladorOperacaoAula.buscarNomesNaFila`.
