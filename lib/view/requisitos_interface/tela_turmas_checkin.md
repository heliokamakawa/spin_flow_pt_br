# Requisitos da Tela: Seleção de Turma para Check-in

> Arquivo de referência permanente para evitar re-especificação entre conversas.

---

## Descrição geral

Tela exibida ao aluno após o login, onde ele visualiza as aulas do dia e realiza ou
gerencia seu check-in.

---

## Dados exibidos por card de aula

### Coluna 1 (esquerda)
- **Nome da aula** (turma.nome) — destaque em negrito
- **Horário** (turma.horarioInicio · turma.duracaoMinutos min)
- **Professora** (nomeProfessora, se houver)

### Coluna 2 (direita)
- **Ocupação** no formato `X/Y` — X = bikes ocupadas, Y = total de bikes da sala
- **Fila** — quantidade de pessoas na fila de espera, exibida apenas quando `totalNaFila > 0`
  - ex.: "3 na fila"

---

## Botão (largura total, destaque visual)

| Status da situação | Texto do botão      | Ativo? | Cor       |
|--------------------|---------------------|--------|-----------|
| `disponivel`       | Check-in            | sim    | sucesso   |
| `lotada`           | Entrar na Fila      | sim    | alerta    |
| `janelaFechada`    | Aguardando          | não    | cinza     |
| `confirmado`       | Reservado           | não    | info      |
| `emFila`           | Na Fila · #N        | não    | cinza     |
| `conflito`         | Conflito de Horário | não    | erro suave|

---

## Regras de negócio

- `vagasOcupadas = totalBikes - vagasDisponiveis`
- `totalNaFila` é consultado no repositório ao montar `SituacaoCheckinAluno`;
  só é relevante para os status `lotada` e `emFila`
- `labelBotao` e `botaoAtivo` vivem no modelo `SituacaoCheckinAluno` (domínio),
  pois são derivados do status (regra de negócio)
- A janela de check-in abre **30 min antes** do início da aula

---

## Estados da tela

| Estado       | Exibição                                     |
|--------------|----------------------------------------------|
| Carregando   | `CircularProgressIndicator` centralizado     |
| Erro         | Mensagem + botão "Tentar novamente"          |
| Lista vazia  | Ícone `event_busy` + "Nenhuma aula hoje."   |
| Lista normal | `ListView` com `RefreshIndicator`            |

---

## Ações do usuário

- Puxar para atualizar (RefreshIndicator)
- Tocar no botão do card → navega para `TelaMapeamentoCheckinAluno`
- Expandir seção de mix para avaliar músicas com estrelas

---

## Navegação

- Ao tocar no botão → `TelaMapeamentoCheckinAluno`
- AppBar com botão de sair do app

---

## Observações

- Mix da aula aparece abaixo do botão, expansível, somente se existir
- Card não possui InkWell global — a ação está concentrada no botão
