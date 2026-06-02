# Migracao Arquitetural

## Objetivo

Migrar o projeto de forma incremental para a arquitetura prometida no diagrama de pacotes:

```text
view -> controller -> domain/servico -> database/dao -> lib/database/sqlite
```

A migracao deve ser feita em fatias pequenas, sempre com validacao apos cada etapa.

## Pastas macro acordadas

```text
lib/
  view/
    componentes/

  controller/

  model/
    modelo/
    dao/
    servico/

  core/
    config/
    validacoes/
    database/
      sqlite/
```

## Convencoes de nomenclatura

- usar portugues nos nomes de arquivos, classes e metodos novos
- usar portugues sem acentos ou caracteres especiais em nomes de arquivos, classes, metodos, variaveis, atributos e identificadores de teste
- `view/form_nome.dart` para cadastro e edicao
- `view/lista_nome.dart` para listagens
- `view/dash_nome.dart` para dashboards
- `view/tela_nome.dart` para telas especificas
- `view/componentes/` para widgets reutilizaveis
- `controller/controlador_nome.dart` para coordenacao de fluxos
- `domain/servico/servico_nome.dart` para regras de aplicacao
- `database/dao/i_dao_nome.dart` para contratos de DAO
- `database/dao/dao_nome_sqlite.dart` para implementacoes futuras explicitamente SQLite
- `model/modelo/modelo_nome.dart` para objetos de dados da aplicacao

## Decisoes arquiteturais

- `view` contem apenas interface.
- `controller` orquestra fluxos iniciados pela view.
- `domain/servico` concentra regras de aplicacao e coordenacao entre DAOs.
- `database/dao` concentra contratos e acesso a dados.
- `core` concentra infraestrutura e configuracoes compartilhadas.
- rotas ficam definidas em `core/config`, mas a escolha da rota de destino pode ser feita pelo controller.
- nao usar `repository` nesta versao, pois o projeto possui uma unica fonte de dados real: SQLite local.
- usar interfaces para DAOs quando uma fatia for migrada.
- migrar por fluxo, nao por pacote inteiro, para manter o app executavel.

## Sincronizacao com requisitos e diagramas

- Sempre que um requisito for alterado, revisar e atualizar `docs/diagramas/dc.md`.
- A revisao deve conferir especialmente nomes de classes, atributos, metodos e associacoes afetadas.
- Campos novos no modelo, no banco ou no fluxo de tela devem aparecer no diagrama de classes quando fizerem parte do dominio.
- Quando a nomenclatura do codigo mudar, o diagrama deve acompanhar a mesma linguagem em portugues usada no projeto.
- Registrar no log de execucao qual requisito motivou a atualizacao do diagrama.

## Validacoes e responsabilidades do modelo

- `model/modelo` deve representar dados da aplicacao e expor propriedades semanticas simples.
- Modelos devem garantir a validade dos proprios dados.
- Modelos podem conter invariantes, consultas e validacoes sobre o proprio estado, como `ehProfessora`, `ehAluno`, `perfilValido`, `emailValido` e `valido`.
- Modelos podem retornar booleanos, codigos ou objetos de violacao de regra.
- Modelos nao devem retornar mensagens de tela, textos de formulario ou decisoes de navegacao.
- Validadores reutilizaveis de baixo nivel devem ficar em `core/validacoes`.
- Validacoes de fluxo/caso de uso devem ser orquestradas pelo `controller`, usando validacoes do modelo e/ou de `core/validacoes`.
- Mensagens padronizadas devem ficar em `core/config`.
- A `view` deve apenas conectar campos, exibir mensagens e executar a navegacao visual.
- O `controller` decide o resultado do fluxo, incluindo mensagens de erro e rota de destino quando houver regra.

## Estado atual

- Fluxos ja migrados para a nova arquitetura: **login** e **recuperacao de senha**.
- `lib/core/` organizada por dominio: `autenticacao/`, `validacoes/`, `lib/database/sqlite/`.
- `lib/controller/autenticacao/` agrupa os controllers do dominio de autenticacao.
- Re-exports em `excluir/` garantem que o legado continua funcionando sem alteracoes.
- Sessao gerenciada via `_SessaoObserver` no `SpinFlowApp` — rotas publicas ignoradas, expiradas redirecionam para `sessaoExpirada`.
- Testes automatizados: 26 passando (unitarios + integracao).
- `flutter analyze` com apenas 7 infos preexistentes de lint/deprecated no legado.

### Estrutura atual da nova arquitetura

```text
lib/
  view/
    componentes/
      campo_email.dart
      campo_senha.dart
      campo_identificador_login.dart
    tela_login.dart
    tela_recuperar_senha.dart

  controller/
    autenticacao/
      controlador_login.dart
    controlador_recuperacao_senha.dart

  model/
    modelo/
      modelo_usuario.dart
    dao/
      i_dao_usuario.dart
      sqlite/
        dao_usuario_sqlite.dart
    servico/
      servico_autenticacao.dart
      servico_recuperacao_senha.dart

  core/
    autenticacao/
      erro.dart
      rotas.dart
      sessao_usuario.dart
    validacoes/
      validador_email.dart
      validador_cpf.dart
    database/
      sqlite/
        conexao.dart
        script.dart

  excluir/   <- legado pendente de migracao
```

## Ordem sugerida

1. ~~Login.~~ (concluido)
2. ~~Recuperacao de senha.~~ (concluido)
3. Check-in do aluno.
4. Mapa de check-in.
5. Dashboard da professora.
6. Listas e formularios CRUD.
7. Reorganizacao fisica final das views e componentes.
8. Reorganizacao final de `core/config`, `core/validacoes` e `lib/database/sqlite`.

## Diretrizes de Organização por Fluxo (2026-05-31)

A partir desta etapa, cada camada principal (view, controller, model, core) terá subpastas organizadas por domínio/fluxo de negócio:

- autenticacao (login, sessão, recuperação de senha)
- checkin (fluxo do aluno)
- gestao_aula (aulas, presença, avaliações)
- gestao_administrativa (cadastros essenciais, usuários, categorias)

### Vantagens
- Facilita manutenção, testes e apresentação do projeto.
- Permite evolução modular e paralela dos fluxos.
- Mantém a arquitetura limpa mesmo com crescimento do sistema.

### Regras
- Cada novo fluxo deve criar suas subpastas em todas as camadas.
- Arquivos migrados devem ser realocados para a subpasta do fluxo correspondente.
- Atualizar esta documentação a cada migração relevante.

Exemplo de estrutura:

```text
lib/
  view/
    autenticacao/
    checkin/
    gestao_aula/
    gestao_administrativa/
  controller/
    autenticacao/
    checkin/
    gestao_aula/
    gestao_administrativa/
  model/
    autenticacao/
    checkin/
    gestao_aula/
    gestao_administrativa/
  core/
    autenticacao/
    checkin/
    gestao_aula/
    gestao_administrativa/
```

## Log de execucao

### 2026-05-31 - Inicio da migracao pelo login

- Criado `model/modelo/modelo_usuario.dart`.
- Criado contrato `database/dao/i_dao_usuario.dart`.
- Criado `domain/servico/servico_autenticacao.dart`.
- Criado `controller/controlador_login.dart`.
- `DAOUsuario.autenticar` passou a implementar o contrato e retornar `ModeloUsuario`.
- `TelaLogin` passou a chamar `ControladorLogin` em vez de acessar `DAOUsuario` diretamente.
- Demais metodos de `DAOUsuario` foram preservados para nao quebrar fluxos ainda nao migrados.
- Validacao: `flutter analyze` sem erros novos de compilacao, mas com 7 infos preexistentes de lint/deprecated.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Isolamento temporario do legado

- Criada a pasta `lib/excluir`.
- Movidos para `lib/excluir` os pacotes ainda nao migrados:
  - `banco`
  - `configuracoes`
  - `dto`
  - `validacoes`
  - `widget`
  - `spim_flow_app.dart`
- Atualizados imports para `package:spin_flow/excluir/...`.
- Raiz atual de `lib/` ficou restrita a:
  - `controller`
  - `model`
  - `excluir`
  - `main.dart`
- Objetivo: deixar explicito o que ja esta na arquitetura nova e o que ainda precisa ser migrado.
- Observacao tecnica: apos a substituicao mecanica de imports, os arquivos `.dart` foram normalizados para UTF-8.
- Validacao: `flutter analyze` sem erros novos de compilacao, mas com 7 infos preexistentes de lint/deprecated.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Criacao de `view` e migracao visual do login

- Criada a pasta `lib/view`.
- Criada a pasta `lib/view/componentes`.
- Copiada a tela de login para `lib/view/tela_login.dart`.
- Copiados os componentes usados pelo login:
  - `lib/view/componentes/campo_email.dart`
  - `lib/view/componentes/campo_senha.dart`
- `lib/excluir/spim_flow_app.dart` passou a importar `TelaLogin` de `lib/view`.
- Observacao: `view` ainda depende temporariamente de `excluir/configuracoes` ate a migracao de `core`.
- Validacao: `flutter analyze` sem erros novos de compilacao, mas com 7 infos preexistentes de lint/deprecated.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Organizacao dos testes automatizados

- Criada estrutura de testes espelhando a arquitetura:
  - `test/unitario/controller`
  - `test/unitario/model/modelo`
  - `test/unitario/domain/servico`
  - `test/integracao/database/dao`
  - `integration_test/sistema`
- Removido `test/widget_test.dart`, pois era o teste padrao do contador e nao representava o app.
- Criados testes unitarios:
  - `test/unitario/controller/controlador_login_test.dart`
  - `test/unitario/model/modelo/modelo_usuario_test.dart`
  - `test/unitario/domain/servico/servico_autenticacao_test.dart`
- Criado teste de integracao com SQLite:
  - `test/integracao/database/dao/dao_usuario_sqlite_test.dart`
- Movidos testes de sistema existentes:
  - `integration_test/sistema/fluxo_aluno_sistema_test.dart`
  - `integration_test/sistema/fluxo_professora_sistema_test.dart`
- Comandos principais:
  - `flutter test test/unitario`
  - `flutter test test/integracao`
  - `flutter test integration_test/sistema -d <device>`
- Validacao: `flutter test test/unitario` executado com sucesso.
- Validacao: `flutter test test/integracao` executado com sucesso.
- Validacao: `flutter analyze` sem erros novos de compilacao, mas com 7 infos preexistentes de lint/deprecated.

### 2026-05-31 - Alinhamento sobre validacoes em modelos

- Decidido que `ModeloUsuario` deve validar a integridade dos proprios dados quando a regra pertencer ao usuario.
- Modelos podem expor validacoes por booleanos, codigos ou violacoes estruturadas.
- Modelos nao devem devolver mensagens de interface.
- Validacoes de formulario/login devem ser orquestradas pelo controller.
- Validadores reutilizaveis devem ir para `core/validacoes`.
- Mensagens padronizadas devem ir para `core/config`.
- Controllers podem selecionar validacoes, mensagens e rotas conforme a regra do fluxo.

### 2026-05-31 - Implementacao correta do DAO de usuario migrado

- Criada a implementacao `lib/database/sqlite/dao/dao_usuario_sqlite.dart`.
- `DAOUsuarioSQLite` implementa `IDAOUsuario`.
- `ControladorLogin` passou a usar `DAOUsuarioSQLite` como implementacao padrao.
- O DAO legado em `lib/excluir/banco/sqlite/dao/dao_usuario.dart` foi mantido apenas para telas ainda nao migradas.
- O DAO legado deixou de implementar `IDAOUsuario`, evitando mistura entre legado e arquitetura nova.
- O teste de integracao do DAO passou a exercitar `DAOUsuarioSQLite`.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso.
- Validacao: `flutter analyze` sem erros novos de compilacao, mas com 7 infos preexistentes de lint/deprecated.

### 2026-05-31 - Requisito de login por e-mail ou CPF

- O identificador do login passou a aceitar e-mail ou CPF.
- `ModeloUsuario` passou a ter o campo `cpf` e validacao semantica `cpfValido`.
- `IDAOUsuario`, `ServicoAutenticacao` e `ControladorLogin` passaram a usar o nome `identificador` no fluxo de autenticacao.
- `DAOUsuarioSQLite` passou a autenticar por `LOWER(email)` ou `cpf`, mantendo senha e usuario ativo como filtros obrigatorios.
- O CPF pode ser informado com ou sem pontuacao na tela de login.
- Criado `view/componentes/campo_identificador_login.dart` para nao alterar o comportamento de `CampoEmail`, que continua adequado para formularios de cadastro.
- Seeds de usuario no SQLite foram atualizadas com CPF para professora e aluno.
- Testes unitarios e de integracao cobrem autenticacao por e-mail e por CPF.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso.
- Validacao: `flutter analyze` sem erros novos de compilacao, mas com 7 infos preexistentes de lint/deprecated.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Criacao de `core/` e correcao das dependencias do fluxo de login

- Criada a pasta `lib/core` com as subpastas `config`, `validacoes` e `lib/database/sqlite`.
- Movidos para `core/config`:
  - `erro.dart`
  - `rotas.dart`
  - `sessao_usuario.dart`
- Movidos para `lib/database/sqlite`:
  - `conexao.dart`
  - `script.dart`
- `lib/excluir/banco/sqlite/conexao.dart` substituido por re-export de `lib/database/sqlite/conexao.dart`, mantendo todos os DAOs legados funcionando sem alteracao.
- Criados validadores reutilizaveis em `core/validacoes`:
  - `validador_email.dart`
  - `validador_cpf.dart`
- Arquivos da nova arquitetura atualizados para importar de `core/` em vez de `excluir/`:
  - `controller/controlador_login.dart`
  - `view/tela_login.dart`
  - `view/componentes/campo_email.dart`
  - `view/componentes/campo_identificador_login.dart` (agora usa `ValidadorEmail` e `ValidadorCpf`)
  - `database/sqlite/dao/dao_usuario_sqlite.dart`
  - `test/unitario/controller/controlador_login_test.dart`
- Observacao: arquivos em `lib/excluir/` continuam importando de `excluir/configuracoes/` sem alteracao, ate serem migrados nos proximos fluxos.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (11/11).
- Validacao: `flutter analyze` sem erros novos, apenas 7 infos preexistentes de lint/deprecated.

### 2026-05-31 - Migracao do fluxo de recuperacao de senha

- Decisao de design: identidade verificada por CPF (campo ja presente em `usuario`), eliminando dependencia de `DAOAluno` que existia no legado.
- Sem sessao no fluxo: recuperacao ocorre antes do login, a identidade e garantida pelos proprios passos (e-mail + CPF).
- Adicionados metodos `buscarPorEmail` e `atualizarSenha` em `IDAOUsuario` e implementados em `DAOUsuarioSQLite`.
- Adicionadas mensagens em `core/config/erro.dart`: `emailNaoEncontrado`, `cpfNaoConfere`, `senhasNaoConferem`.
- Criado `domain/servico/servico_recuperacao_senha.dart` com `verificarEmail`, `verificarCpf` e `redefinirSenha`.
- Criado `controller/controlador_recuperacao_senha.dart` com `ResultadoRecuperacao` e tres metodos de fluxo.
- Criada `view/tela_recuperar_senha.dart` com 3 etapas (e-mail, CPF, nova senha) e tela de confirmacao.
- Testes unitarios do controller e do servico com fake do DAO.
- Testes de integracao do DAO para `buscarPorEmail` e `atualizarSenha`.
- Fakes existentes em `controlador_login_test.dart` e `servico_autenticacao_test.dart` atualizados para implementar os novos metodos da interface.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter analyze` sem erros novos, apenas 7 infos preexistentes de lint/deprecated.

### 2026-05-31 - Reorganizacao por dominio e implementacao de sessao

- Pastas reorganizadas por dominio de negocio dentro de cada camada macro.
- `core/config/` renomeada para `core/autenticacao/` — agrupa `erro.dart`, `rotas.dart` e `sessao_usuario.dart` do dominio de autenticacao.
- `controller/controlador_login.dart` movido para `controller/autenticacao/controlador_login.dart`.
- `lib/excluir/configuracoes/sessao_usuario.dart` atualizado para re-exportar de `core/autenticacao/sessao_usuario.dart`, garantindo singleton unico entre legado e nova arquitetura.
- Implementado `_SessaoObserver` em `excluir/spim_flow_app.dart`:
  - Verifica expiracao de sessao a cada navegacao.
  - Rotas publicas (`login`, `splash`, `recuperarSenha`, `sessaoExpirada`) sao ignoradas.
  - Sessao expirada encerra a sessao e redireciona para `sessaoExpirada`.
  - Sessao ativa registra atividade para renovar o timeout.
- Corrigido bug de singleton: antes da correcao, `ControladorLogin` e `_SessaoObserver` usavam classes estaticas diferentes para `SessaoUsuario`.
- `excluir/widget/tela_login.dart` e `view/tela_login.dart` atualizados para importar de `controller/autenticacao/`.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter analyze` sem erros novos, apenas 7 infos preexistentes de lint/deprecated.


### 2026-05-31 - Adocao de get_it como container de injecao de dependencia

- Adicionada dependencia `get_it: ^8.0.0` ao `pubspec.yaml`.
- Criado `lib/core/di/injecao.dart` com a funcao `configurarDependencias()`.
- Registro das dependencias:
  - `IDAOUsuario` como `lazySingleton` (implementacao: `DAOUsuarioSQLite`)
  - `ServicoAutenticacao` e `ServicoRecuperacaoSenha` como `lazySingleton`
  - `ControladorLogin` e `ControladorRecuperacaoSenha` como `factory`
- `main.dart` atualizado para chamar `configurarDependencias()` antes de `runApp`.
- Controllers atualizados: parametros de servico passaram a ser `required`, removendo a criacao interna de `DAOUsuarioSQLite`.
- Views atualizadas para obter controllers via `GetIt.I<Controller>()`.
- Testes nao usam `get_it`: controllers continuam recebendo fakes via construtor.
- Teste do controlador de login atualizado para refletir novo comportamento da professora (`requerEscolhaPerfil = true`).
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter analyze` sem erros novos, apenas infos preexistentes de lint/deprecated.

### 2026-05-31 - Diretriz de sincronizacao do diagrama de classes

- Registrada a regra: toda alteracao de requisito deve revisar `docs/diagramas/dc.md`.
- O diagrama de classes foi atualizado para representar `Usuario`, `PerfilUsuario`, `cpf`, `senha`, perfil e validacoes relacionadas ao login por e-mail ou CPF.
- A associacao opcional entre `Usuario` e `Aluno` foi explicitada para refletir que o perfil aluno possui vinculo com dados de aluno.

### 2026-05-31 - Padrao de nomes em portugues sem acentos

- Mantida a decisao de usar portugues nas nomenclaturas do projeto.
- Definida a regra: identificadores de codigo nao devem usar acentos, cedilha ou caracteres especiais.
- A regra vale para arquivos, classes, metodos, variaveis, atributos, nomes de testes e chaves internas.
- Textos exibidos na interface podem usar acentos normalmente quando o arquivo estiver com codificacao correta.
- Exemplo correto: `ListaManutencoes`, `ControladorManutencao`, `descricao`, `posicaoProfessora`.

### 2026-05-31 - Finalizacao do cadastro de manutencoes

- `ListaManutencoes` corrigida para usar identificadores sem acentos.
- `FormManutencao` atualizado para o padrao novo de formulario da gestao administrativa.
- `DropdownButtonFormField` atualizado para `initialValue`, evitando lints novos do Flutter.
- `ControladorManutencao`, `ServicoManutencao`, `DAOManutencaoSQLite`, `DAOBikeSQLite` e `DAOTipoManutencaoSQLite` conectados via `get_it`.
- `TelaGestaoAdministrativa` passou a expor o item `Manutencoes` com link para formulario e lista novos.
- Rotas `cadastroManutencao`, `manutencao` e `listaManutencoes` passaram a abrir as telas novas em `view/gestao_administrativa`.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter analyze` sem erros, apenas infos preexistentes de lint/deprecated.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Implementacao do cadastro de turmas

- Revisado o legado de turma: `form_turma.dart`, `lista_turmas.dart`, `dao_turma.dart` e `dto_turma.dart`.
- Decisao de requisito a partir do prototipo: a tela nova usa identificacao, horario de inicio, duracao em minutos, um dia da semana, sala e ativo.
- O campo legado `descricao` nao foi levado para a tela nova porque nao aparece no prototipo atual.
- O banco ainda usa `dias_semana` como JSON; a nova implementacao grava o dia selecionado como lista com um unico item para manter compatibilidade com a estrutura existente.
- Criados:
  - `model/gestao_administrativa/modelo_turma.dart`
  - `database/dao/i_dao_turma.dart`
  - `database/sqlite/dao/dao_turma_sqlite.dart`
  - `domain/servico/servico_turma.dart`
  - `controller/gestao_administrativa/controlador_turma.dart`
  - `view/gestao_administrativa/form_turma.dart`
  - `view/gestao_administrativa/lista_turmas.dart`
- `get_it` atualizado com `IDAOTurma`, `ServicoTurma` e `ControladorTurma`.
- `TelaGestaoAdministrativa` passou a exibir o item `Turmas`.
- Rotas `cadastroTurma` e `listaTurmas` passaram a abrir as telas novas em `view/gestao_administrativa`.
- `docs/diagramas/dc.md` atualizado para refletir o modelo novo de `Turma` com `DiaSemana diaSemana` em vez de `List~DiaSemana~ diasSemana` e sem `descricao`.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter analyze` sem erros, apenas infos preexistentes de lint/deprecated.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Ajuste de turma para multiplos dias da semana

- Corrigido requisito de turma: dia da semana voltou a ser selecao multipla, como no legado.
- `ModeloTurma` passou de `diaSemana` para `diasSemana`.
- `DAOTurmaSQLite` passou a gravar e ler todos os dias selecionados no JSON `dias_semana`.
- A regra de conflito de horario passou a verificar intersecao entre os dias existentes e os novos dias selecionados.
- `FormTurma` passou a usar chips de selecao multipla para dias da semana.
- O campo `Dias da semana` foi movido para o final do formulario, depois de `Ativo`, para melhorar a visualizacao.
- `ListaTurmas` passou a exibir todos os dias selecionados.
- `docs/diagramas/dc.md` atualizado para `List~DiaSemana~ diasSemana`.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter analyze` sem erros novos, apenas infos preexistentes de lint/deprecated.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Normalizacao relacional dos dias da turma

- Ajustada a modelagem de turma para representar multiplos dias em tabela associativa.
- Criada a tabela `turma_dia_semana` no script SQLite com `turma_id` e `dia_semana`.
- Seeds fixos e dinamicos passaram a inserir os dias tambem em `turma_dia_semana`.
- `DAOTurmaSQLite` passou a salvar os dias em `turma_dia_semana`.
- A coluna legada `turma.dias_semana` foi mantida temporariamente como espelho de compatibilidade para codigo ainda em `excluir`.
- A leitura do DAO novo prioriza `turma_dia_semana` e usa `turma.dias_semana` apenas como fallback.
- A validacao de conflito passou a usar a tabela associativa.
- `docs/diagramas/dc.md` atualizado com `TurmaDiaSemana`; `Turma` nao mantem mais `diasSemana` como atributo direto no diagrama.
- Validacao: analise isolada da fatia de turma sem issues.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Implementacao do cadastro de grupos de alunos

- Revisado o legado de grupos de alunos: formulario, lista, DTO, DAO e script SQLite.
- Requisito mantido: grupo possui nome, descricao, alunos selecionados e estado ativo.
- Normalizada a relacao N:N entre grupo e aluno por meio da tabela associativa `grupo_aluno`.
- A coluna legada `grupo_alunos.aluno_ids` foi mantida temporariamente como espelho de compatibilidade para codigo ainda em `excluir`.
- A leitura do DAO novo prioriza `grupo_aluno` e usa `grupo_alunos.aluno_ids` apenas como fallback.
- Criados:
  - `model/gestao_administrativa/modelo_grupo_alunos.dart`
  - `database/dao/i_dao_aluno.dart`
  - `database/dao/i_dao_grupo_alunos.dart`
  - `database/sqlite/dao/dao_aluno_sqlite.dart`
  - `database/sqlite/dao/dao_grupo_alunos_sqlite.dart`
  - `domain/servico/servico_grupo_alunos.dart`
  - `controller/gestao_administrativa/controlador_grupo_alunos.dart`
  - `view/gestao_administrativa/form_grupo_alunos.dart`
  - `view/gestao_administrativa/lista_grupos_alunos.dart`
- `get_it` atualizado com `IDAOAluno`, `IDAOGrupoAlunos`, `ServicoGrupoAlunos` e `ControladorGrupoAlunos`.
- `TelaGestaoAdministrativa` passou a exibir o item `Grupos de Alunos`.
- Rotas `cadastroGrupoAlunos` e `listaGruposAlunos` passaram a abrir as telas novas em `view/gestao_administrativa`.
- `docs/diagramas/dc.md` atualizado com a classe associativa `GrupoAluno`.
- Validacao: analise isolada da fatia de grupos de alunos sem issues.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Ajuste do dashboard do aluno

- Requisito ajustado: apos login do aluno, a rota `dashboardAluno` deve abrir uma tela com duas abas.
- A primeira aba e a principal: `Check-in`, reutilizando exatamente o widget `TelaCheckinAluno`.
- A segunda aba mantem o conteudo anterior de `Meu Painel`.
- `TelaCheckinAluno` passou a aceitar `exibirAppBar`, mantendo a rota direta `/checkin-aluno` com AppBar e permitindo uso embutido no dashboard sem AppBar duplicada.
- O drawer do aluno passou a alternar entre as abas `Check-in` e `Meu Painel`, em vez de empilhar uma nova rota para o check-in dentro do proprio dashboard.
- `docs/diagramas/dc.md` revisado: sem alteracao necessaria, pois a mudanca foi de navegacao/interface e nao alterou classes, atributos ou associacoes de dominio.
- Validacao: analise isolada de `tela_dashboard_aluno.dart` e `tela_checkin_aluno.dart` sem issues.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Ajuste visual do check-in do aluno

- Seeds dinamicos de turmas do check-in passaram a usar nomes naturais de aula:
  - `Spinning Essencial`
  - `Spinning Performance`
  - `Spinning Intensivo`
- Estados de teste como vaga, lotada e janela fechada deixaram de aparecer no nome da aula.
- No card de check-in, disponibilidade, vagas, fila e janela de reserva passaram a aparecer como texto informativo, sem aparencia de botao.
- A acao principal passou a ser um botao grande e chamativo:
  - `Check-in`, quando a janela esta aberta e ha vagas.
  - `Fila de espera`, quando a janela esta aberta e a turma esta lotada.
  - `Aguarde...`, desabilitado, quando a janela de check-in ainda nao abriu.
- `docs/diagramas/dc.md` revisado: sem alteracao necessaria, pois a mudanca foi de seed/interface e nao alterou classes, atributos ou associacoes de dominio.
- Validacao: analise isolada de `script.dart` e `tela_checkin_aluno.dart` sem issues.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Refinamento do card de check-in

- O card do check-in foi reorganizado para aproveitar melhor o espaco horizontal.
- Em larguras maiores, dados da aula ficam a esquerda e disponibilidade/acao ficam a direita.
- Em larguras menores, o card empilha as informacoes para preservar leitura.
- A disponibilidade e a fila de espera continuam como texto informativo, sem aparencia de botao.
- O botao principal ganhou maior presenca visual por largura minima, altura, fonte maior, icone maior, borda e cor contextual.
- O texto de acao para turma lotada passou a ser `Entrar em fila de espera`.
- Validacao: analise isolada de `tela_checkin_aluno.dart` sem issues.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Ajuste do mapa de check-in pelo prototipo 10-class-detail

- Revisado `prototipacoes-html-css/10-class-detail.html`.
- A tela de entrada na sala (`TelaMapaCheckin`) passou a seguir o fluxo do prototipo:
  - resumo da aula no topo
  - cards de vagas e janela de check-in
  - grade visual de bikes
  - bikes ocupadas destacadas com nome do aluno
  - selecao de bike livre antes da confirmacao
  - botao inferior `Confirmar bike NN`
  - chamada separada para o mix da aula
- A reserva deixou de acontecer ao tocar na bike; o toque apenas seleciona a bike livre.
- O check-in e confirmado apenas pelo botao principal.
- A turma dinamica `Spinning Performance` passou a usar sala 3x5 e ocupacoes de simulacao proximas ao prototipo.
- `docs/diagramas/dc.md` revisado: sem alteracao necessaria, pois a mudanca foi de seed/interface e nao alterou classes, atributos ou associacoes de dominio.
- Validacao: analise isolada de `tela_mapa_checkin.dart` e `script.dart` sem issues.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Fluxo de confirmacao e cancelamento do check-in

- Ao confirmar uma bike no mapa de check-in, o sistema nao exibe mais dialogo de sucesso.
- Apos a confirmacao, o aluno volta automaticamente para a lista de aulas do dashboard.
- A lista de aulas identifica o check-in ativo do aluno logado.
- Quando o aluno ja possui check-in na aula, o botao principal muda para `Cancelar check-in`.
- O cancelamento exibe dialogo de confirmacao antes de cancelar.
- Apos cancelar, a lista e recarregada e a acao da aula volta a ser `Check-in`.
- Validacao: analise isolada de `tela_checkin_aluno.dart` e `tela_mapa_checkin.dart` sem issues.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Seed de mix com 10 musicas

- O seed de musicas foi ampliado para 10 faixas contextualizadas para aula de spinning.
- O mix principal passou a ser `Mix Performance`, com 10 musicas:
  - `Warm Wheels`
  - `Ride the Fire`
  - `Climb Higher`
  - `Pulse Sprint`
  - `Deep Resistance`
  - `Beat Control`
  - `Out of Saddle`
  - `Final Push`
  - `Slow Burn`
  - `Cool Down Flow`
- Os vinculos auxiliares `musica_categoria`, `musica_video_aula` e `mix_musica` foram atualizados para refletir as 10 faixas.
- `docs/diagramas/dc.md` revisado: sem alteracao necessaria, pois a mudanca foi de dados de simulacao.
- Validacao: analise isolada de `script.dart` sem issues.
- Validacao: `flutter test test/integracao` executado com sucesso.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Bloqueio de check-in em turmas sobrepostas

- Requisito adicionado: o aluno nao pode ter check-in ativo em outra turma no mesmo horario.
- A regra foi implementada em `DAOCheckin.reservarComValidacao`, impedindo a reserva mesmo se o usuario chegar pela rota do mapa.
- A promocao automatica da fila de espera tambem passa a ignorar candidatos que ja possuem check-in em turma sobreposta.
- A lista de aulas do aluno identifica conflitos de horario com check-ins ativos do aluno logado.
- Quando existe conflito, a aula exibe `Horario ocupado`, informa a turma conflitante e bloqueia a acao de check-in.
- `docs/diagramas/dc.md` revisado: sem alteracao necessaria, pois a mudanca e regra de negocio de `Checkin` ja representada no dominio.
- Validacao: analise isolada de `dao_checkin.dart` e `tela_checkin_aluno.dart` sem issues.
- Validacao: `flutter build web` executado com sucesso.

### 2026-05-31 - Selecao de alunos no FormGrupoAlunos substituida por busca com lista

- `view/componentes/campo_busca_multipla.dart` criado: componente generico reutilizavel.
  - Campo de busca com filtro em tempo real, excluindo ja selecionados das sugestoes.
  - Dropdown de sugestoes limitado a 180 px com scroll.
  - Lista scrollavel dos selecionados (max 200 px) com botao de remocao.
  - Integra com `FormField` via `erroTexto`.
- `FormGrupoAlunos` atualizado: chips substituidos por `CampoBuscaMultipla<ModeloAluno>`.
- Validacao: `flutter analyze lib/view/gestao_administrativa/form_grupo_alunos.dart lib/view/componentes/campo_busca_multipla.dart` sem issues.

### 2026-05-31 - Implementacao do Repertorio na aba da professora

- Decisao arquitetural: `docs/dc.md` atualizado.
  - `Mix` perdeu `dataInicio` e `dataFim` (pertencem a `TurmaMix`).
  - Adicionada `MixMusica` com `posicao: int` para representar 10 slots ordenados.
  - Associacao `Mix --> Musica` substituida por `Mix *-- MixMusica --> Musica`.
- `lib/database/sqlite/script.dart` atualizado.
  - Tabela `mix` sem `data_inicio` e `data_fim`.
  - Novas tabelas normalizadas: `musica_categoria`, `musica_video_aula`, `mix_musica` (com `posicao`).
  - Seeds atualizados para popular as novas tabelas.
- `TelaDashboardProfessora` expandida para 3 abas: **Aulas** | **Repertorio** | **Administrativo**.
- Criados em `model/gestao_aula/`: `ModeloArtistaBanda`, `ModeloCategoriaMusica`, `ModeloVideoAula`, `ModeloMusica`, `ModeloMix`.
- Criados DAOs: `IDAOArtistaBanda`, `IDAOCategoriaMusica`, `IDAOVideoAula`, `IDAOMusica`, `IDAOMix` e implementacoes SQLite.
  - `DAOMusicaSQLite` usa JOIN com `artista_banda` para retornar `nomeArtista` no modelo.
  - `DAOMusicaSQLite` gerencia `musica_categoria` e `musica_video_aula` normalizadas.
  - `DAOMixSQLite` persiste e le posicoes ordenadas de `mix_musica`.
- Criados servicos: `ServicoArtistaBanda`, `ServicoMusica`, `ServicoMix`.
  - `ServicoMusica.atualizarCategorias`: cria categoria se nao existir (busca por nome, case-insensitive).
  - `ServicoMusica.atualizarVideos`: cria VideoAula se URL nao existir (link = nome).
- Criados controllers: `ControladorArtistaBanda`, `ControladorMusica`, `ControladorMix`.
- `core/di/injecao.dart` atualizado com todos os novos DAOs, servicos e controllers.
- Criadas views em `view/gestao_aula/`:
  - `TelaRepertorio`: menu com 5 cards seguindo prototipo 21.
  - `FormArtistaBanda`: nome*, descricao, link, URL da foto.
  - `FormMusica`: nome*, artista* (dropdown + botao Novo que navega para FormArtistaBanda).
  - `FormCategoriasMusicaFlow`: busca musica via Autocomplete, add/remove categorias (cria se nova).
  - `FormVideoaulasMusicaFlow`: busca musica via Autocomplete, add/remove URLs de videoaulas.
  - `FormMix`: nome*, descricao, 10 slots numerados com dropdown + Adicionar + remover.
- Validacao: `flutter analyze lib/` com apenas 7 infos preexistentes no legado.
- Validacao: `flutter test test/unitario test/integracao` executado com sucesso (26/26).

### 2026-05-31 - Ajuste dos indicadores do painel do aluno

- Requisito ajustado: a aba `Meu Painel` deve apresentar somente informacoes calculaveis com os dados atuais.
- Removidos indicadores sem base confiavel no estado atual do sistema:
  - `Presenca media`
  - `Sequencia atual`
  - `Melhor sequencia`
- Mantidos indicadores coerentes com os registros existentes:
  - aulas realizadas no mes
  - check-ins futuros
  - aulas registradas nos ultimos 3 meses
  - turmas disponiveis hoje
  - check-ins ativos hoje
  - ultima aula registrada
  - proxima aula do dia
- `docs/diagramas/dc.md` revisado: sem alteracao necessaria, pois a mudanca e de apresentacao e regra de calculo de tela, sem novo atributo ou associacao de dominio.
- Validacao: analise isolada de `tela_dashboard_aluno.dart` sem issues.

### 2026-05-31 - Logout padronizado no topo das telas

- Requisito adicionado: telas autenticadas devem apresentar a opcao `Sair` na parte superior, em local padronizado.
- Criado `AcaoSairAppBar` em `view/componentes/acao_sair_app_bar.dart`.
- O componente encerra a sessao e retorna para `Rotas.login` removendo as rotas anteriores da pilha.
- A acao foi aplicada em dashboards, telas de aluno, telas da professora, cadastros, listas e componentes herdados que ainda estao ativos.
- Diretriz: novas telas autenticadas com `AppBar` devem incluir `actions: const [AcaoSairAppBar()]` ou preservar as acoes existentes e adicionar `AcaoSairAppBar` ao final.
- `docs/diagramas/dc.md` revisado: sem alteracao necessaria, pois a mudanca e de navegacao/interface, sem novo atributo ou associacao de dominio.
- Validacao: `flutter analyze` executado; sem erros, apenas `info` preexistentes de estilo/deprecacao.
- Validacao: `flutter build web` executado com sucesso.

### 2026-06-01 - Avaliacao de musicas pelo aluno no mapa de check-in

- Requisito adicionado: o aluno pode indicar de 1 a 5 estrelas o quanto gosta de cada musica do mix da aula.
- Criada a tabela associativa `avaliacao_musica`, relacionando `aluno` e `musica` com `nota` e `atualizado_em`.
- Criado `DAOAvaliacaoMusica` no legado ativo do mapa de check-in para buscar e salvar as notas.
- `TelaMapaCheckin` passou a exibir 5 estrelas para cada musica do mix e persistir a nota selecionada.
- `docs/dc.md` e `docs/diagramas/dc.md` atualizados com a classe associativa `AvaliacaoMusica`.
- Validacao: analise isolada de `tela_mapa_checkin.dart`, `dao_avaliacao_musica.dart` e `script.dart` sem issues.

### 2026-06-01 - Busca de check-ins com avaliacao de musicas no painel do aluno

- Removido do `Meu Painel` o card de destaque `Check-in da aula`.
- Adicionada a secao `Avaliar musicas por check-in` com campo de busca por turma, data ou mix.
- Cada check-in encontrado pode ser expandido para exibir as musicas do mix vigente da turma.
- As estrelas usam a tabela `avaliacao_musica`, reaproveitando as notas ja registradas no mapa de check-in.
- Validacao: analise isolada de `tela_dashboard_aluno.dart`, `dao_avaliacao_musica.dart` e `script.dart` sem issues.

### 2026-06-01 - Otimizacao do painel do aluno

- Removida a secao `Acessos rapidos` do `Meu Painel`.
- Adicionados botoes compactos no inicio do painel para `Historico de aulas` e `Agenda completa`.
- Removido o acesso direto `Mix da turma` do painel.
- A avaliacao de musicas passou a mostrar somente um check-in por vez: por padrao, a ultima turma participada; com busca, o check-in mais recente correspondente ao termo.
- Validacao: analise isolada de `tela_dashboard_aluno.dart` sem issues.

### 2026-06-01 - Migracao SQLite para avaliacao de musicas

- A versao do banco SQLite subiu de 1 para 2.
- `onUpgrade` passou a criar `avaliacao_musica` quando o app abre com um banco antigo.
- Motivo: em hot restart/web, o `deleteDatabase` pode nao apagar a base antiga se houver conexao anterior aberta, mantendo schema sem a tabela nova.
- Validacao: analise isolada de `conexao.dart`, `script.dart`, `tela_dashboard_aluno.dart`, `tela_mapa_checkin.dart` e `dao_avaliacao_musica.dart` sem issues.
- Validacao: `flutter test test/integracao` executado com sucesso.

### 2026-06-01 - Mix completo e recolhido no painel do aluno

- A versao do banco SQLite subiu de 2 para 3.
- `onUpgrade` passou a garantir a tabela `mix_musica` e o seed de 10 musicas no `Mix Performance` para bancos antigos.
- A secao de avaliacao do `Meu Painel` passou a exibir o mix recolhido por padrao.
- O cabecalho da expansao agora representa o mix, mostrando turma, data e quantidade de musicas.
- Validacao: analise isolada de `conexao.dart`, `script.dart` e `tela_dashboard_aluno.dart` sem issues.
- Validacao: `flutter test test/integracao` executado com sucesso.

### 2026-06-01 - Coerencia dos seeds de contexto real

- A versao do banco SQLite subiu de 3 para 4.
- Normalizadas as posicoes da professora nas salas de simulacao para ficarem coerentes com as grades usadas nas telas.
- A turma dinamica `Spinning Performance` passou a ter mix vigente desde a data do check-in de ontem do aluno logado.
- A turma dinamica `Spinning Intensivo` passou a representar lotacao real: professora em uma posicao e tres bikes de aluno ocupadas.
- `onUpgrade` passou a aplicar essas normalizacoes em bancos ja existentes.
- Validacao: analise isolada de `conexao.dart` e `script.dart` sem issues.
- Validacao: `flutter test test/integracao` executado com sucesso.

### 2026-06-01 - Cores semanticas no mapa de check-in

- Bikes livres passaram de verde para branco com borda, reforcando a ideia de espaco vazio/disponivel.
- Bikes ocupadas passaram de vermelho para preto, evitando associar ocupacao a erro.
- A legenda e as celulas dos mapas de check-in foram ajustadas para manter contraste e leitura.

### 2026-06-01 - Lista compacta de musicas no check-in

- O modal do mix no mapa de check-in passou a usar linhas compactas no formato `Musica (Artista)` com avaliacao na mesma linha.
- Removidos textos redundantes da lista para caber mais musicas visiveis de uma vez.
- A altura do modal foi ampliada proporcionalmente a tela.

### 2026-06-01 - Avaliacao de mix em modal no painel do aluno

- A avaliacao de musicas no `Meu Painel` deixou de expandir a lista dentro da tela principal.
- O card do check-in agora abre um modal com o mix e as estrelas em linhas compactas.
- O painel permanece enxuto enquanto a lista de musicas ganha mais area util no modal.

### 2026-06-01 - Indicadores em duas colunas no painel do aluno

- A secao `Indicadores` do `Meu Painel` passou de linhas empilhadas para uma grade de 2 colunas.
- Cada indicador usa um card compacto com icone, valor, titulo e subtitulo.
- Valores longos, como `Ultima aula`, foram limitados para evitar estouro visual.

### 2026-06-01 - Remocao de proxima aula do painel do aluno

- A secao `Proxima aula` foi removida do `Meu Painel`.
- O calculo interno dessa informacao tambem foi removido, evitando estado sem uso.
