# Painel de Frequência da Professora

## Localização
Aba "Aulas" → botão "Painel de Frequência"

## Objetivo
Mostrar os alunos com maior frequência nas turmas da professora logada,
com busca por nome e acesso aos detalhes de cada aluno.

## Carregamento inicial
- Ao abrir, carrega automaticamente todos os alunos que frequentaram
  turmas da professora logada, ordenados por número de check-ins (decrescente).
- Exibe os 10 primeiros (top 10) quando não há texto na busca.
- Mostra indicador de carregamento durante a busca inicial.

## Campo de busca
- TextField sempre visível no topo, abaixo do AppBar.
- Placeholder: "Buscar aluno por nome..."
- Conforme a professora digita, a lista é filtrada em tempo real (sem nova query).
- Quando há texto na busca: exibe todos os alunos correspondentes (não só o top 10).
- Quando a busca é apagada: volta a exibir o top 10.

## Cabeçalho da lista
- Sem busca: "Top 10 mais frequentes"
- Com busca: "Resultados para '[texto]'"
- Exibido como subtítulo acima da lista.

## Lista de alunos
- Cada item mostra:
  - Avatar com iniciais do nome (cor primária)
  - Nome do aluno
  - Chip com total de check-ins (ex.: "12 check-ins")
- Toque em um item → abre TelaDetalheAlunoProfessora.

## Estados vazios
- Carregando: CircularProgressIndicator centralizado.
- Sem dados após carga: ícone people_outline + "Nenhum aluno frequentou estas turmas ainda."
- Sem resultado na busca: ícone search_off + "Nenhum aluno encontrado para '[texto]'."
- Erro: mensagem de erro + botão "Tentar novamente".
