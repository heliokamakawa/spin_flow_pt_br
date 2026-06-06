# SpinFlow PT-BR

Projeto didatico em portugues para Engenharia de Software, reunindo documentacao, analise, modelagem, prototipacao e implementacao de um sistema Flutter para um estudio de indoor cycling.

O projeto usa o dominio da Pulse Studio Indoor para demonstrar, de forma incremental, a passagem de requisitos e modelos para uma aplicacao executavel com persistencia local em SQLite.

## Objetivos Didaticos

- documentar requisitos funcionais e nao funcionais
- registrar decisoes de analise e modelagem
- manter diagramas e prototipos como evidencias do processo
- implementar uma aplicacao Flutter funcional
- demonstrar arquitetura em camadas
- organizar testes unitarios, de integracao e de sistema
- apoiar aulas e avaliacoes de Engenharia de Software em portugues

## Arquitetura em Migracao

A arquitetura-alvo esta organizada em quatro pastas macro:

```text
lib/
  view/
  controller/
  model/
  core/
```

Durante a migracao incremental, codigo legado ainda nao adequado a arquitetura nova fica temporariamente em:

```text
lib/excluir/
```

O fluxo de login ja foi iniciado como exemplo da nova organizacao:

```text
view -> controller -> domain/servico -> database/dao -> SQLite
```

Mais detalhes estao em:

- `lib_docs/migracao.md`
- `lib_docs/02_diretrizes_dev/04_arquitetura_camadas.md`

## Perfis de Acesso

| Perfil | E-mail | CPF | Senha |
| --- | --- | --- | --- |
| Professora | `professora@gmail.com` | `111.222.333-44` | `123` |
| Aluno | `aluna@gmail.com` | `555.666.777-88` | `123` |

O login aceita e-mail ou CPF como identificador.

## Como Rodar

```bash
flutter pub get
flutter run
```

Para web:

```bash
flutter run -d web-server
```

## Testes

### Unitarios

```bash
flutter test test/unitario
```

### Integracao

```bash
flutter test test/integracao
```

### Sistema

Os testes de sistema navegam pelo app como usuario final.

```bash
flutter test integration_test/sistema -d <DEVICE_ID>
```

## Estrutura dos Testes

```text
test/
  unitario/
    controller/
    model/
  integracao/
    model/
      dao/

integration_test/
  sistema/
```

## Documentacao e Modelagem

- `docs/`: especificacao, requisitos e documentos LaTeX
- `docs/diagramas/`: diagramas e arquivos Astah
- `lib_docs/`: diretrizes de desenvolvimento, mapeamento de requisitos e logs de execucao
- `prototipacoes-html-css/`: prototipos HTML/CSS usados como apoio visual

## Tecnologias

- Flutter
- Dart
- SQLite
- `sqflite`
- `sqflite_common_ffi`
- `sqflite_common_ffi_web`

## Natureza do Projeto

Este repositorio tem finalidade didatica. O objetivo principal e servir como exemplo completo em portugues para disciplinas de Engenharia de Software, conectando documentacao, analise, modelagem, prototipacao, implementacao e testes.
