# Cadastros e Entidades

## Cadastros simples

- Fabricante
- CategoriaMusica
- TipoManutencao
- ArtistaBanda
- Aluno
- Sala
- VideoAula

## Cadastros com associa��es

- Bike -> Fabricante
- Musica -> ArtistaBanda + Categorias + VideoAulas
- Mix -> Musicas
- Turma -> Sala + DiasSemana
- GrupoAlunos -> Alunos
- Manutencao -> Bike + TipoManutencao
- Checkin -> Aluno + Turma + posi��o
- TurmaMix -> Turma + Mix

## Entidades principais (DTO)

- `DTOFabricante`, `DTOTipoManutencao`, `DTOArtistaBanda`, `DTOCategoriaMusica`, `DTOVideoAula`
- `DTOAluno`, `DTOSala`, `DTOBike`, `DTOMusica`, `DTOMix`, `DTOTurma`
- `DTOGrupoAlunos`, `DTOManutencao`, `DTOCheckin`, `DTOTurmaMix`, `DTOPosicaoBike`

## DAO por entidade (SQLite)

Todos os DTOs operacionais possuem DAO em `lib/banco/sqlite/dao/`.

## Observa��o

Este arquivo � vis�o r�pida para dev humano. O mapeamento de requisitos detalhado est� em:
- `lib_docs/01_requisitos/01_mapeamento_requisitos.md`
