# Requisitos da Tela: Dashboard do Aluno (TelaTurmasCheckin)

> Arquivo de referência permanente para evitar re-especificação entre conversas.

---

## Descrição geral

Dashboard principal do aluno após o login. Organizado em duas abas:
- **Aba 1 — Check-in**: visualizar aulas do dia e gerenciar check-in.
- **Aba 2 — Meu Painel**: nível, participação, indicadores e avaliações de mix.

---

## Estrutura de abas

| Índice | Ícone | Label | Conteúdo |
|--------|-------|-------|----------|
| 0 | `directions_bike` | Check-in | Lista de turmas do dia |
| 1 | `person` | Meu Painel | Nível + participação + indicadores + avaliações |

Ambas as abas são carregadas na inicialização (`Future.wait`).

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

### Cartão de Nível (topo da aba)
Primeiro elemento da aba Meu Painel. Cartão com **fundo em gradiente** conforme o
nível do aluno e uma **timeline de 3 pontos** (Prata → Ouro → Diamante).

**Regra de nível** (`NivelAluno.fromSemanasSeguidas`, base = `IndicadoresAluno.semanasSeguidas`):

| Nível    | Semanas seguidas | Gradiente        |
|----------|------------------|------------------|
| Iniciante| 0                | cinza neutro     |
| Prata    | ≥ 1              | prata            |
| Ouro     | ≥ 3              | ouro             |
| Diamante | ≥ 5              | azul diamante    |

- **Semanas seguidas:** semanas de calendário consecutivas (segunda como âncora) com ao
  menos 1 aula, terminando na semana da aula mais recente (`_calcularSemanasSeguidas`).
- **Cabeçalho:** ícone do nível + "Nível X" + subtítulo com semanas seguidas e quanto
  falta para o próximo nível (ou "nível máximo" no Diamante).
- **Timeline:** 3 pontos fixos. Pontos alcançados ficam preenchidos (círculo branco com
  ícone na cor do nível); o ponto atual recebe destaque (maior, com anel branco); os
  conectores até o nível atual ficam sólidos. Texto/contraste escuro em Prata/Ouro e
  branco em Diamante/Iniciante.

### Seção Aulas Realizadas
Três contadores lado a lado com `VerticalDivider`:

| Contador | Dado | Período |
|----------|------|---------|
| Semana   | `EstatisticasParticipacao.semana` | segunda-feira da semana atual até hoje |
| Mês      | `EstatisticasParticipacao.mes`    | primeiro dia do mês até hoje |
| Ano      | `EstatisticasParticipacao.ano`    | primeiro dia do ano até hoje |

Fonte: tabela `aula_realizada` via `IDAOAulaRealizada.contarPorAlunoNoPeriodo`.

### Seção Indicadores
Quatro indicadores de engajamento (modelo `IndicadoresAluno`), abaixo de "Aulas Realizadas".

Dois contadores grandes lado a lado (com `VerticalDivider`):

| Indicador        | Dado | Regra |
|------------------|------|-------|
| Aulas este mês          | `IndicadoresAluno.aulasMes`      | aulas do primeiro dia do mês até hoje (mesmo valor de "Mês") |
| Semanas ativas (3 meses)| `IndicadoresAluno.semanasAtivas` | semanas distintas (segunda como início) com ≥1 aula nos últimos 3 meses |

> O rótulo deixa explícito o recorte de 3 meses para não ser confundido com as
> **semanas seguidas** do cartão de nível (que contam a sequência no histórico todo).

Dois cartões informativos (título + detalhe):

| Cartão           | Dado | Texto |
|------------------|------|-------|
| Total de aulas   | `IndicadoresAluno.totalTresMeses` | `N nos últimos 3 meses` |
| Sequência atual  | `IndicadoresAluno.sequenciaAtual` | `N dias consecutivos` (ou "Nenhuma aula recente" se 0) |

Regras de cálculo (em `RepositorioCheckinAluno.buscarPainelAluno`):
- Janela de 3 meses = `DateTime(ano, mês − 2, 1)` até hoje (mês atual + 2 anteriores).
- **Semanas ativas:** conta chaves distintas da segunda-feira da semana de cada data com aula, dentro da janela de 3 meses (`_contarSemanasAtivas`).
- **Sequência atual:** dias de calendário consecutivos com aula, terminando na aula mais recente (`_calcularSequenciaDias`); datas distintas no nível de dia. Hoje a base só registra presenças.

Fonte adicional: `IDAOAulaRealizada.listarDatasRealizadas` (datas distintas, dia, desc).

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
