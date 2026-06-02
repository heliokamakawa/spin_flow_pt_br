# Arquitetura em Camadas

## Objetivo

Organizar o projeto em quatro pastas macro, alinhadas ao diagrama de pacotes da disciplina:

- `view`
- `controller`
- `model`
- `core`

Essa organização deve tornar explicita a separacao entre interface, coordenacao de fluxos, regras/dados da aplicacao e infraestrutura compartilhada.

## Estrutura proposta

```text
lib/
  view/
    componentes/
    form_nome.dart
    lista_nome.dart
    dash_nome.dart
    tela_nome.dart

  controller/

  model/
    servico/
    dao/
    modelo/

  core/
    config/
    validacoes/
    database/
      sqlite/
```

## Responsabilidades

### `view`

Contem telas e componentes visuais.

Responsabilidades:
- renderizar a interface
- controlar estado visual local
- ler campos do formulario
- chamar controllers
- navegar quando o controller retornar o resultado esperado

Organizacao:
- telas ficam diretamente em `view/`
- componentes reutilizaveis ficam em `view/componentes/`

Convencao de nomes para telas:
- `form_nome.dart` para cadastros e edicoes
- `lista_nome.dart` para listagens
- `dash_nome.dart` para dashboards
- `tela_nome.dart` para telas especificas fora dos grupos anteriores

Nomenclatura de codigo:
- usar portugues em arquivos, classes, metodos, variaveis e atributos
- nao usar acentos, cedilha ou caracteres especiais em identificadores de codigo
- textos visiveis da interface podem usar acentos quando a codificacao do arquivo estiver correta

Evitar:
- acessar banco diretamente
- executar consultas em DAO
- concentrar regras de negocio

Textos de interface:
- labels, hints e placeholders ficam **inline no widget** — sem arquivo de constantes intermediario
- mensagens de erro de fluxo (ex: login invalido) vem do controller via resultado, usando `Erro.xxx` de `core/config/erro.dart`
- validacoes de campo obrigatorio usam `Erro.obrigatorio` diretamente no validator do widget

Navegacao em telas de gestao (padrao `_ItemGestao`):
- clicar no **titulo/descricao** abre o **formulario de cadastro** (acao principal)
- icone de lista (`list_alt`) abre a **listagem**
- icone de adicionar (`add_circle_outline`) abre o **formulario de cadastro**
- razao: o uso mais frequente e criar ou editar um registro, nao consultar a lista

Padrao de acoes em listas (`lista_nome.dart`):
- acoes de cada item ficam **visiveis diretamente** no trailing do `ListTile` — sem `PopupMenuButton` nem menu oculto
- dois `IconButton` lado a lado: `Icons.edit` (laranja) e `Icons.delete` (vermelho)
- clicar no tile (onTap) abre o formulario de edicao
- `CircleAvatar` com cor verde (ativo) ou cinza (inativo) como leading
- `Card` com `margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4)`
- razao: acoes ocultas exigem mais cliques e reduzem a descoberta de funcionalidades

### `controller`

Coordena as acoes iniciadas pela view.

Responsabilidades:
- receber dados da interface
- chamar servicos
- tratar sucesso/erro de caso de uso
- preparar resultados para a view
- selecionar mensagens, validacoes e rotas conforme a regra do fluxo

Evitar:
- montar widgets
- executar SQL
- conter logica de persistencia

### `domain/servico`

Contem regras de aplicacao e casos de uso.

Responsabilidades:
- validar regras de negocio
- orquestrar um ou mais DAOs
- decidir quando uma operacao pode ou nao ocorrer
- retornar modelos ou resultados simples para controllers

Evitar:
- conhecer widgets ou `BuildContext`
- navegar entre telas

### `database/dao`

Contem a logica de acesso a dados.

Responsabilidades:
- inserir, atualizar, excluir e consultar dados
- converter registros do banco para modelos
- manter SQL e detalhes de persistencia fora das telas

Evitar:
- implementar regra de tela
- acessar estado visual

### `model/modelo`

Contem objetos de transporte de dados.

Responsabilidades:
- representar dados usados pela aplicacao
- transportar informacoes entre DAO, servico, controller e view
- expor propriedades semanticas simples sobre o proprio estado
- garantir a validade dos proprios dados quando a regra pertencer ao modelo
- retornar booleanos, codigos ou objetos de violacao para regras do proprio estado

Observacao:
- o projeto nao precisa criar entidades complexas se os modelos ja representam bem os dados usados.
- mensagens de tela, textos de formulario e decisoes de navegacao nao devem ficar no modelo.
- validacoes de formulario ou caso de uso devem ser orquestradas pelo controller, podendo usar validacoes do modelo.

### `core/config`

Contem configuracoes **transversais** ao app inteiro — usadas por mais de uma camada ou dominio.

O que fica aqui:
- `rotas.dart` — nomes de rota usados por controllers e views
- `sessao_usuario.dart` — singleton de sessao, acessado por controllers e pelo observer de navegacao
- `erro.dart` — mensagens de erro retornadas por controllers para a view exibir

O que **nao** fica aqui:
- textos de interface (labels, hints) — ficam inline nos widgets
- constantes especificas de um unico dominio — ficam no proprio controller ou servico

`core/` nao deve ser organizado por dominio. Se um arquivo so serve a um fluxo, ele nao pertence ao `core/`.

### `core/validacoes`

Contem validadores reutilizaveis.

Exemplos:
- validador de URL
- validador de email
- validador de senha

Validacoes reutilizaveis devem ficar aqui. Modelos e controllers podem usar esses validadores. Validacoes especificas de fluxo devem ser orquestradas pelo controller.

### `database`

Contem infraestrutura de banco.

Responsabilidades:
- conexao singleton
- selecao de factory por plataforma
- scripts de criacao e seed

Sugestao:
- manter detalhes especificos do SQLite em `lib/database/sqlite`.

## Regra de dependencia

Fluxo desejado:

```text
view -> controller -> domain/servico -> database/dao -> database -> sqlite
```

Modelos podem trafegar entre as camadas:

```text
view <-> controller <-> servico <-> dao
```

`core` pode ser usado pelas demais camadas quando representar infraestrutura ou configuracao compartilhada.

## Plano de migracao sugerido

1. Criar as quatro pastas macro.
2. Mover `configuracoes` para `core/config`.
3. Mover `validacoes` para `core/validacoes`.
4. Mover DTOs para `model/modelo`, renomeando gradualmente para `Modelo...`.
5. Mover DAOs para `database/dao`.
6. Mover conexao e script SQLite para `lib/database/sqlite`.
7. Mover telas para `view/`, mantendo componentes em `view/componentes/`.
8. Renomear telas conforme a convencao `form_`, `lista_`, `dash_` e `tela_`.
9. Criar controller e servico para o fluxo de login.
10. Migrar telas principais aos poucos, priorizando:
   - login
   - recuperacao de senha
   - check-in do aluno
   - dashboard da professora
   - mapa operacional

## Pasta temporaria `excluir`

Durante a migracao incremental, codigo ainda nao adequado a arquitetura nova pode ficar temporariamente em `lib/excluir`.

Regras:
- `excluir` nao e arquitetura final.
- arquivos em `excluir` devem ser migrados aos poucos para `view`, `controller`, `model` ou `core`.
- novos fluxos nao devem ser criados dentro de `excluir`.
- cada migracao deve atualizar `lib_docs/migracao.md`.

## Estrategia de re-export para migracao incremental

Quando um arquivo de infraestrutura compartilhada (ex: conexao, config) e movido para `core/` mas ainda e referenciado por muitos arquivos legados em `excluir/`, o arquivo original pode ser substituido por um re-export:

```dart
// lib/excluir/banco/sqlite/conexao.dart
export 'package:spin_flow/database/sqlite/conexao.dart';
```

Isso permite:
- mover a implementacao real para `core/` imediatamente
- manter todos os arquivos legados funcionando sem alteracao
- evitar duplicacao de singleton (ex: conexao de banco)

O arquivo re-export em `excluir/` e removido quando o ultimo arquivo legado que o importa for migrado.

## Decisao recomendada para este projeto

Usar as quatro pastas macro como arquitetura oficial:

- `view`
- `controller`
- `model`
- `core`

Na primeira etapa, a migracao pode ser estrutural e explicita, sem reescrever todos os fluxos. Em seguida, os fluxos mais importantes podem ser convertidos para controller/servico de forma incremental.

## Injecao de dependencia com get_it

O projeto usa `get_it` como container de injecao de dependencia.

### Por que get_it

- Service locator simples, sem geracao de codigo
- Mais usado em projetos Flutter de mercado
- Registro explicito e legivel em um unico ponto
- Compativel com testes (controllers continuam aceitando injecao via construtor)

### Onde fica o registro

```
lib/core/di/injecao.dart
```

A funcao `configurarDependencias()` e chamada em `main.dart` antes do `runApp`.

### Regras de registro

- **DAOs** — `registerLazySingleton<IDAONome>()` registrado pela **interface**, nao pela implementacao concreta. Permite trocar a implementacao sem alterar nenhum outro arquivo.
- **Servicos** — `registerLazySingleton<ServicoNome>()`: compartilham o mesmo DAO durante a sessao do app.
- **Controllers** — `registerFactory<ControladorNome>()`: cada tela recebe sua propria instancia ao ser criada.

### Regras nos controllers

- Controllers **nao criam** suas dependencias. O construtor recebe tudo como `required`.
- Nenhum controller importa `DAOUsuarioSQLite` ou qualquer implementacao concreta de DAO.
- Em testes, o controller e instanciado diretamente com um fake — o `get_it` nao e usado nos testes unitarios.

### Exemplo de uso em view

```dart
// view/tela_login.dart
final _controladorLogin = GetIt.I<ControladorLogin>();
```

### Exemplo de registro em injecao.dart

```dart
getIt.registerLazySingleton<IDAOUsuario>(() => DAOUsuarioSQLite());
getIt.registerLazySingleton<ServicoAutenticacao>(
  () => ServicoAutenticacao(daoUsuario: getIt<IDAOUsuario>()),
);
getIt.registerFactory<ControladorLogin>(
  () => ControladorLogin(servicoAutenticacao: getIt<ServicoAutenticacao>()),
);
```
