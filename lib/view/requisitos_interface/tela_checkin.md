# Requisitos da Tela: Mapa de Check-in do Aluno

> Arquivo de referência permanente para evitar re-especificação entre conversas.

---

## Descrição geral

Tela exibida após o aluno selecionar uma turma na lista de aulas. Mostra a grade de
bikes da sala, permite selecionar uma bike disponível e confirmar o check-in.

---

## Cabeçalho compacto

| Campo        | Fonte                             |
|--------------|-----------------------------------|
| Nome da aula | `dados.mapa.turma.nome`           |
| Professora   | `dados.nomeProfessora`            |
| Horário      | `turma.horarioInicio · duracaoMinutos min` |
| Dias semana  | `turma.diasSemana[].dbValue` — abreviados, separados por `·` |

---

## Grade de bikes

### Cores e representações

| Estado         | Cor (CoresApp)        | Texto na célula |
|----------------|-----------------------|-----------------|
| Livre          | `bikeLivre`           | Número da bike (grande, texto escuro) |
| Ocupada        | `bikeOcupada`         | Número da bike (grande, branco) |
| Professora     | `bikeProfessora`      | "P" (grande, branco) |
| Manutenção     | `bikeManutencao`      | Número da bike (grande, branco) |
| Minha reserva  | `bikeMinhaReserva`    | Número da bike (grande, branco) |
| Selecionada    | `bikeMinhaReserva`    | Número + borda branca destacada |
| Sem bike       | cinza suave           | "—" |

- Células mostram **somente o número** da bike, **grande e centralizado** (otimizado para celular)
- Sem textos secundários ou labels de status nas células

---

## Painel informativo

Exibido abaixo da grade. Atualiza ao tocar uma bike.

| Bike tocada       | Exibição no painel                              |
|-------------------|-------------------------------------------------|
| Nenhuma           | (vazio / instrução sutil)                       |
| Livre             | "Bike selecionada para check-in"                |
| Ocupada (outro)   | Primeiro nome do aluno + nome da bike           |
| Manutenção        | "Em manutenção" + motivo (`descricao`)          |
| Minha reserva     | "Sua reserva" + nome da bike                   |
| Professora        | "Bike da professora"                            |

---

## Mix da aula

- Card/seção abaixo do painel, com o nome do mix
- **Expansível**: ao tocar expande listando todas as músicas
- Toda a tela fica em `SingleChildScrollView` — sem scroll interno do mix
- Cada música exibe: posição, nome, artista e **5 estrelas** para avaliação
- Avaliação é persistida no banco e carregada ao abrir a tela
- Componente: `PainelMix` (reutilizável — também usado na lista de aulas)

---

## Painel de fila de espera

Exibido **abaixo do botão de ação**, somente quando a turma está `lotada` e `totalNaFila > 0`.

- Cabeçalho: ícone `people_outline` + "Fila de espera · N pessoa(s)" em cor `alerta`
- Seta `expand_more` / `expand_less` indica estado de expansão
- Ao tocar: expande e carrega os nomes da fila sob demanda (lazy load)
- Lista exibida com posição (1, 2, 3…) + nome do aluno, ordenada por ordem de entrada
- Enquanto carrega: `CircularProgressIndicator` compacto
- Nomes são cacheados localmente — recarregar o mapa limpa o cache

---

## Botão de ação principal (largura total, abaixo do mix)

| Condição (prioridade)          | Texto do botão                  | Ativo? | Cor     |
|--------------------------------|---------------------------------|--------|---------|
| Tem check-in ativo             | Cancelar Reserva                | sim    | erro    |
| Está na fila (`posicaoNaFila`) | Na Fila · #N · Sair             | sim    | alerta  |
| Janela fechada                 | Aguardando · Abre 30min antes   | não    | cinza   |
| Turma lotada                   | Entrar na Fila                  | sim    | alerta  |
| Bike livre selecionada         | Confirmar Check-in              | sim    | sucesso |
| Nenhuma bike selecionada       | Selecione uma bike disponível   | não    | cinza   |

---

## Regras de negócio (domínio)

- `bikeDisponivelParaCheckin(fila, coluna)` — verifica se a célula é válida para seleção
  - Não é posição da professora
  - Existe bike nessa posição
  - Bike não está em manutenção
  - Bike não está ocupada por outro aluno
- `motivoManutencaoEm(fila, coluna)` — retorna a `descricao` da manutenção ativa da bike
- A janela abre **30 min antes** do início da aula

---

## Navegação

- Após **check-in confirmado** → `Navigator.pop()` (retorna à lista; a lista recarrega e exibe "Reservado")
- Após **cancelamento** → recarrega mapa (permanece na tela)
- AppBar com botão de sair do app

---

## Estados da tela

| Estado     | Exibição                                    |
|------------|---------------------------------------------|
| Carregando | `CircularProgressIndicator` centralizado    |
| Erro       | Mensagem + botão "Tentar novamente"         |
| Normal     | Layout completo descrito acima              |
