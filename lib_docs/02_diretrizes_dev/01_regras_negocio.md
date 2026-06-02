# Regras de Neg�cio

## Regras base de valida��o

| Regra | Aplica��o |
|---|---|
| texto obrigat�rio | `nome` (todas entidades principais) |
| e-mail v�lido | `Aluno.email` |
| telefone v�lido | `Aluno.telefone` |
| URL v�lida (quando informada) | `Aluno.instagram/facebook/tiktok`, `ArtistaBanda.link`, `VideoAula.linkVideo` |
| n�mero > 0 | `Sala.numeroFilas`, `Sala.numeroColunas`, `Turma.duracaoMinutos` |
| n�mero >= 0 | `PosicaoBike.fila/coluna`, `Sala.posicaoProfessora` |
| lista n�o vazia | `Turma.diasSemana` |
| sem repeti��o | `Turma.diasSemana` |
| data n�o futura | `Aluno.dataNascimento`, `Bike.dataCadastro`, `Manutencao.dataSolicitacao/dataRealizacao`, `Checkin.data` |

## Regras espec�ficas

- `Sala.posicaoProfessora` deve estar entre `0` e `numeroColunas - 1`.
- `Manutencao.dataRealizacao` deve ser `>= dataSolicitacao` quando preenchida.
- `Mix/TurmaMix.dataFim` deve ser `>= dataInicio` quando preenchida.
- n�o pode haver duas `PosicaoBike` iguais (mesma sala, fila, coluna).

## Check-in

- um aluno n�o pode ter 2 check-ins ativos para a mesma turma/data.
- uma posi��o (fila/coluna) n�o pode ter 2 check-ins ativos para a mesma turma/data.
- cancelamento � l�gico (`ativo = false`) e preserva hist�rico.

## Turma x Mix

- `TurmaMix` representa vig�ncia do mix por turma.
- apenas 1 v�nculo ativo por turma no per�odo vigente.

## Manuten��o

- manuten��o pendente impacta disponibilidade operacional da bike.
- ao concluir manuten��o, disponibilidade deve ser recalculada.

## Regra de documenta��o

- documenta��o operacional em markdown deve ficar em `lib_docs/`.
- evitar novos `.md` operacionais fora de `lib_docs/`.
