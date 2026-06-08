# Requisitos — tela_mapa_aula.dart

## Contexto
Tela acessada pela professora ao entrar em uma turma no dia de aula.
Exibe o mapa de bikes da sala com estado de cada posição e permite ações operacionais.

## Parâmetros de entrada
| Parâmetro   | Tipo   | Obrigatório | Descrição                   |
|-------------|--------|-------------|------------------------------|
| `turmaId`   | int    | sim         | ID da turma selecionada      |
| `nomeTurma` | String | sim         | Nome exibido no AppBar       |

## Layout geral
- AppBar com logo SpinFlow, ações e botão de Instagram (condicional).
- Abaixo do AppBar, em sequência vertical:
  1. Legenda de cores das bikes
  2. **Seletor de mix** (campo de seleção da turma)
  3. Grid de bikes (ocupa o espaço restante)

## Seletor de mix
- Exibido sempre, mesmo sem mixes cadastrados.
- Mostra o mix atualmente associado à turma (`turma.mixId`).
- Permite escolher entre todos os mixes **ativos** cadastrados.
- Inclui opção "Nenhum" (valor `null`) para desassociar o mix.
- Ao selecionar, salva imediatamente no banco via controlador.
- Não recarrega o mapa inteiro — atualiza apenas o estado local da turma.
- Feedback de sucesso: snackbar "Mix atualizado."
- Feedback de erro: snackbar com mensagem de erro em cor de erro.

## Grid de bikes
- Uma célula por posição (fila × coluna) da sala.
- Estados de célula:
  | Estado        | Cor            | Label          | Ação ao tocar         |
  |---------------|----------------|----------------|-----------------------|
  | Professora    | bikeProfessora | "Profa"        | nenhuma               |
  | Manutenção    | bikeManutencao | "Manut"        | resolver manutenção   |
  | Ocupada       | bikeOcupada    | nome do aluno  | confirmar cancelamento|
  | Livre         | bikeLivre      | nome da bike   | registrar manutenção  |
  | Sem bike      | textoFraco 18% | "—"            | nenhuma               |

## Legenda
- Linha horizontal com chips: Professora · Reservada · Livre · Manutenção.

## Painel Instagram
- Ícone `alternate_email` na AppBar, visível apenas se houver alunos com check-in.
- Abre bottom sheet com chips de @handles.
- Chips removíveis individualmente.
- Botão "Copiar marcações" copia a string para clipboard.

## Diálogo de manutenção
- Aberto ao tocar em bike livre.
- Campos: tipo de manutenção (dropdown, obrigatório) e motivo (textarea, opcional).
- Confirma com "Registrar"; cancela com "Não".
