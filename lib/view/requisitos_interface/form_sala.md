# Requisitos da Tela: Formulário de Sala

> Arquivo de referência permanente para evitar re-especificação entre conversas.

---

## Descrição geral

Formulário usado tanto na inclusão quanto na atualização de uma sala. Acessado a partir da lista de salas (`lista_salas.dart`).

---

## Campos obrigatórios

| Campo                  | Tipo   | Restrições                                      |
|------------------------|--------|-------------------------------------------------|
| Nome                   | texto  | Não pode ser vazio                              |
| Número de filas        | inteiro | Entre 1 e 6                                   |
| Número de colunas      | inteiro | Entre 1 e 10                                  |
| Fila da professora     | inteiro | Entre 1 e `numeroFilas` (dentro da grade)     |
| Coluna da professora   | inteiro | Entre 1 e `numeroColunas` (dentro da grade)   |

Todos os 5 campos são obrigatórios e validados no formulário **e** no domínio (`Sala.validar()`).

---

## Campo informativo (não persistido)

| Campo              | Tipo    | Função                                                     |
|--------------------|---------|------------------------------------------------------------|
| Quantidade de bikes | inteiro | Usado apenas na prévia visual da grade; não salvo no banco |

---

## Validação em dois níveis

1. **Formulário** (`validator` de cada `TextFormField`):
   - Bloqueia o salvamento com erro *inline* no campo.
   - Para fila/coluna da professora: max dinâmico = valor atual de filas/colunas. O formulário é reconstruído a cada alteração nas dimensões via `addListener → setState`.

2. **Domínio** (`DominioSala.validar()` → `Sala.validar()`):
   - Nome vazio.
   - Filas fora de 1–6 ou colunas fora de 1–10.
   - Posição da professora fora da grade (`posicaoProfessoraValida`).
   - Erros exibidos como snackbar.

---

## Prévia da grade

- Renderiza a grade `filas × colunas` em tempo real conforme o usuário digita.
- Célula da professora marcada com "Prof" na cor primária.
- Células sem bike marcadas com "–".
- Exibe contador de bikes restantes / excesso.

---

## Switch ativo/inativo

- Presente apenas no fluxo de **atualização**.
- Controlado pelo componente `CampoAtivo`.

---

## Ações

| Ação   | Comportamento                                        |
|--------|------------------------------------------------------|
| Salvar | Valida formulário → valida domínio → persiste → pop(true) |
| Voltar | `Navigator.pop()` sem salvar                        |

---

## Estados

| Estado    | Exibição                                      |
|-----------|-----------------------------------------------|
| Normal    | Formulário completo com prévia                |
| Salvando  | Botão exibe `CircularProgressIndicator`       |
| Erro      | Snackbar vermelho com mensagem do domínio     |
