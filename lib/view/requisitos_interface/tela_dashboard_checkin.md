# Requisitos da Tela: Dashboard do Aluno (TelaTurmasCheckin)

> Arquivo de referência permanente para evitar re-especificação entre conversas.

---

## Descrição geral

Dashboard principal do aluno após o login. Organizado em três abas:
- **Aba 1 — Check-in**: visualizar aulas do dia e gerenciar check-in.
- **Aba 2 — Meu Painel**: informações pessoais, histórico de participação e avaliações de mix.
- **Aba 3 — Histórico**: histórico de aulas realizadas (presenças) com filtro por período.

---

## Estrutura de abas

| Índice | Ícone | Label | Conteúdo |
|--------|-------|-------|----------|
| 0 | `directions_bike` | Check-in | Lista de turmas do dia |
| 1 | `person` | Meu Painel | Perfil + participação + avaliações |
| 2 | `history` | Histórico | Aulas realizadas com filtro de período |

As abas Check-in e Painel são carregadas na inicialização (`Future.wait`).
A aba Histórico é carregada **sob demanda** (lazy) na primeira vez que é aberta.

---

## Aba 0 — Check-in

### Dados exibidos por card de aula

#### Coluna 1 (esquerda)
- **Nome da aula** (turma.nome) — destaque em negrito
- **Horário** (turma.horarioInicio · turma.duracaoMinutos min)
- **Professora** (nomeProfessora, se houver)

#### Coluna 2 (direita)
- **Ocupação** no formato `X/Y` — X = bikes ocupadas, Y = total de bikes da sala
- **Fila** — quantidade de pessoas na fila de espera, exibida apenas quando `totalNaFila > 0`

### Botão principal (largura total)

| Status           | Texto do botão      | Ativo? | Cor        |
|------------------|---------------------|--------|------------|
| `disponivel`     | Check-in            | sim    | sucesso    |
| `lotada`         | Entrar na Fila      | sim    | alerta     |
| `confirmado`     | Cancelar Check-in   | sim    | erro       |
| `janelaFechada`  | Aguardando          | não    | cinza      |
| `emFila`         | Na Fila · #N        | não    | cinza      |
| `conflito`       | Conflito de Horário | não    | cinza      |

### Botão secundário — apenas para `emFila`

Exibido abaixo do botão principal quando `status == emFila`:

| Texto       | Ativo? | Estilo                        |
|-------------|--------|-------------------------------|
| Sair da Fila | sim   | OutlinedButton, cor alerta    |

- Ao tocar: diálogo de confirmação → chama `sairDaFila(filaId)` → permanece na lista e recarrega.

### Estados da aba

| Estado       | Exibição                                     |
|--------------|----------------------------------------------|
| Carregando   | `CircularProgressIndicator` centralizado     |
| Erro         | Mensagem + botão "Tentar novamente"          |
| Lista vazia  | Ícone `event_busy` + "Nenhuma aula hoje."   |
| Lista normal | `ListView` com `RefreshIndicator`            |

### Botão fila de espera (bottom do card)

Exibido somente quando `totalNaFila > 0`, separado por `Divider`:

- Linha: ícone `people_outline` (alerta) + "Fila de espera · N pessoa(s)" + `chevron_right`
- Ao tocar: abre `ModalBottomSheet` com título, nome da turma e lista de nomes numerados
- Nomes carregados via `buscarNomesNaFila` com `FutureBuilder` (exibe indicador enquanto carrega)
- Disponível para todos os status que tenham `totalNaFila > 0` (`lotada`, `emFila`)

### Ações do usuário (aba Check-in)

- Puxar para atualizar (`RefreshIndicator`)
- Tocar no botão do card → navega para `TelaMapeamentoCheckinAluno`
- Card `confirmado` → diálogo de confirmação de cancelamento
- Card `conflito` / `janelaFechada` → snackbar informativo

---

## Aba 1 — Meu Painel

### Seção Perfil
- Nome completo
- E-mail
- Telefone (se preenchido)
- Data de nascimento no formato `DD/MM/AAAA (X anos)` (se preenchida)
- Instagram, TikTok, Facebook (se preenchidos)
- Observações em itálico (se preenchidas)

### Seção Aulas Realizadas
Três contadores lado a lado com `VerticalDivider`:

| Contador | Dado | Período |
|----------|------|---------|
| Semana   | `EstatisticasParticipacao.semana` | segunda-feira da semana atual até hoje |
| Mês      | `EstatisticasParticipacao.mes`    | primeiro dia do mês até hoje |
| Ano      | `EstatisticasParticipacao.ano`    | primeiro dia do ano até hoje |

Fonte: tabela `aula_realizada` via `IDAOAulaRealizada.contarPorAlunoNoPeriodo`.

### Seção Avaliação de Mix
Seletor de modo com `SegmentedButton` (3 opções):

| Modo   | Ícone               | Conteúdo exibido |
|--------|---------------------|------------------|
| Top 5  | `star`              | 5 músicas mais bem avaliadas pelo aluno |
| Todas  | `list`              | Todas as músicas avaliadas, ordem por nota desc |
| Média  | `analytics_outlined`| Nota média com estrelas e total de músicas avaliadas |

- Se o aluno não avaliou nenhuma música: exibe "Nenhuma música avaliada ainda."
- Cada item de lista exibe: nome da música, artista, estrelas (1–5)
- A seção "Média" exibe o valor com 1 casa decimal e estrelas visuais

### Estados da aba Painel

| Estado     | Exibição |
|------------|----------|
| Carregando | `CircularProgressIndicator` centralizado |
| Erro       | Mensagem + botão "Tentar novamente" |
| Sem dados  | "Nenhum dado disponível." |
| Normal     | `ListView` com `RefreshIndicator` e as 3 seções |

---

## Aba 2 — Histórico

Lista as aulas **realizadas** (presenças) do aluno, da mais recente para a mais antiga.

### Fonte de dados
- Tabela `aula_realizada` (apenas registros com `ativo = 1`) com JOIN em `turma` para
  obter nome e horário.
- Caminho: `IDAOAulaRealizada.listarPorAluno` → `RepositorioCheckinAluno.listarHistoricoAluno`
  → `ControladorCheckinAluno.listarHistoricoAluno`.
- Modelo de domínio: `RegistroHistoricoAula` (`nomeTurma`, `data`, `horarioInicio`, `presente`).

> **Status Presente/Falta:** hoje a base registra somente presenças, portanto todos os
> itens aparecem como **Presente**. O campo `presente` no modelo já existe para permitir
> a distinção Presente/Falta caso a regra evolua.

### Filtros de período (linha superior)
Três botões; o selecionado fica em destaque (negrito, cor primária). Filtragem **em memória**
sobre a lista já carregada — não refaz consulta ao banco.

| Filtro     | Regra |
|------------|-------|
| Todas      | Todos os registros |
| Este mês   | `data >= primeiro dia do mês atual` |
| 3 meses    | `data >= primeiro dia do mês, dois meses atrás` (mês atual + 2 anteriores) |

### Card de aula
- **Nome da turma** — negrito.
- Linha: `DD/MM/AAAA - HH:MM` + rótulo de status (**Presente** em cor sucesso / **Falta** em cor erro).
- Data formatada com `DateFormat('dd/MM/yyyy', 'pt_BR')`; horário vem de `turma.horarioInicio`.

### Estados da aba
| Estado      | Exibição |
|-------------|----------|
| Carregando  | `CircularProgressIndicator` centralizado |
| Erro        | Mensagem + botão "Tentar novamente" |
| Lista vazia | Ícone `event_busy` + "Nenhuma aula no período." |
| Lista normal| `ListView` com `RefreshIndicator` (puxar para atualizar) |

---

## Regras de negócio

- `vagasOcupadas = totalBikes - vagasDisponiveis`
- `totalNaFila` só é relevante para os status `lotada` e `emFila`
- `labelBotao` e `botaoAtivo` vivem em `SituacaoCheckinAluno` (domínio)
- Janela de check-in abre **30 min antes** do início da aula
- Contagem de semana usa `DateTime.weekday` (segunda = 1) como início

---

## Navegação

- AppBar com botão de sair do app
- Aba Check-in → toca no botão → `TelaMapeamentoCheckinAluno`

---

## Observações

- Mix da aula aparece abaixo do botão no card, expansível, somente se existir
- Card não possui InkWell global — a ação está concentrada no botão
- `SingleTickerProviderStateMixin` gerencia o `TabController`
- Ao retornar de `TelaMapeamentoCheckinAluno`, recarrega somente a aba Check-in
