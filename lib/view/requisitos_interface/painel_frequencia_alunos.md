# Requisitos — Painel de Frequência dos Alunos

## Descrição
Tela acessada a partir da aba "Aulas" no dashboard da professora. Exibe a frequência consolidada dos alunos por turma em um período selecionado.

## Acesso
- Botão "Painel de Frequência" na barra inferior da `TelaOperacaoAula`.

## Filtros (sempre visíveis no topo)
| Campo | Tipo | Obrigatório | Padrão |
|-------|------|-------------|--------|
| Turma | Dropdown | Sim | Primeira turma ativa (ordem alfabética) |
| De (data início) | DatePicker | Sim | Primeiro dia do mês corrente |
| Até (data fim) | DatePicker | Sim | Hoje |
| Nome do aluno | TextField | Não | Vazio (filtra localmente) |

- "De" nunca pode ser posterior a "Até" (corrigido automaticamente).
- Busca é disparada pelo botão **Buscar**.
- Filtro por nome filtra a lista local (sem nova query).

## Dados exibidos por linha
| Coluna | Descrição |
|--------|-----------|
| Nome | Nome do aluno |
| Check-ins | Total de check-ins confirmados no período (numerador/denominador: `X/Y`) |
| Frequência | Percentual formatado com 1 decimal (`XX.X%`) ou `—` quando dados indisponíveis |

- **Dado indisponível**: quando não houve nenhuma aula realizada no período para a turma (`total_aulas = 0`). Exibir `—` na coluna Frequência. A linha permanece visível.
- Linhas com zero check-ins **não são exibidas** (apenas alunos que frequentaram ao menos uma aula).

## Ordenação
- Cabeçalho das colunas Nome e Frequência são clicáveis para ordenar.
- Alternância: clique na mesma coluna inverte ASC↔DESC.
- Indicador visual de seta ao lado do nome da coluna ativa.
- Padrão inicial: frequência decrescente.

## Estado vazio
Quando nenhum aluno tem check-in no período/turma selecionados:
> Ícone `people_outline` + texto "Nenhum dado de frequência no período selecionado."

## Estado antes da primeira busca
> Texto orientativo: "Selecione uma turma e período e clique em Buscar."

## Rodapé
- Contador: `N aluno(s)`
- Média de frequência (excluindo linhas com dado indisponível): `Média: XX.X%`

## Cores de frequência
| Faixa | Cor |
|-------|-----|
| ≥ 75% | Verde (`sucesso`) |
| 50–74% | Laranja (`alerta`) |
| < 50% | Vermelho (`erro`) |
| Indisponível | Cinza |

## Denominador (total_aulas)
Contagem de datas distintas com ao menos um check-in ativo para a turma no período. Representa os dias em que a aula foi efetivamente realizada.