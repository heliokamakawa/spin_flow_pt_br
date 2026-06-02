# Casos de Uso � Descri��es

## Tabela de Casos de Uso

| ID | Caso de Uso | Professora | Aluno |
|---|---|:---:|:---:|
| UC01 | Autenticar no Sistema | ? | ? |
| UC02 | Realizar Checkin | ? | ? |
| UC03 | Verificar Disponibilidade da Bike *(�include� de UC02)* | � | � |
| UC04 | Visualizar Mapa da Sala *(�include� de UC02)* | � | � |
| UC05 | Cancelar Checkin *(�extend� ? UC02)* | ? qualquer | ? pr�prio |
| UC06 | Gerenciar Alunos e Grupos | ? | � |
| UC07 | Gerenciar Bikes e Fabricantes | ? | � |
| UC08 | Gerenciar Manuten��es | ? | � |
| UC09 | Cancelar Manuten��o *(�extend� ? UC08)* | ? | � |
| UC10 | Gerenciar Salas e Turmas | ? | � |
| UC11 | Verificar Disponibilidade de Hor�rio *(�include� de UC10)* | � | � |
| UC12 | Associar Mix � Turma *(�extend� ? UC10)* | ? | � |
| UC13 | Gerenciar Mixes e Repert�rio | ? | � |
| UC14 | Consultar Agenda Semanal | ? | ? |
| UC15 | Consultar Mix e Repert�rio | ? | ? |
| UC16 | Consultar Hist�rico de Presen�a | � | ? |
| UC17 | Visualizar Dashboard | ? | ? |
| UC18 | Gerar Relat�rios Gerenciais | ? | � |

---

## Descri��es

### UC01 � Autenticar no Sistema
O usu�rio informa suas credenciais para acessar o sistema. O perfil (Professora ou Aluno) determina quais funcionalidades estar�o dispon�veis ap�s o login. Senha m�nima de 6 caracteres.

### UC02 � Realizar Checkin
O aluno ou professora reserva uma posi��o de bike em uma turma para uma data espec�fica. O sistema valida a disponibilidade (`bikeEhLivre`) e exibe o mapa da sala antes de confirmar a reserva. A data deve cair em um dos dias da semana da turma e n�o pode ser anterior � data atual.

### UC03 � Verificar Disponibilidade da Bike *(�include�)*
Invocado sempre que UC02 � executado. Chama `bikeEhLivre(fila, coluna)`, verificando: posi��o dentro dos limites da sala, aus�ncia de checkin ativo na mesma posi��o/turma/data e exist�ncia de vaga na turma.

### UC04 � Visualizar Mapa da Sala *(�include�)*
Invocado sempre que UC02 � executado. Exibe a grade visual (fila � coluna) com o estado de cada posi��o: livre, reservada, em manuten��o ou posi��o da professora. Professora v� o nome do aluno em posi��es reservadas; aluno v� apenas ocupa��o an�nima.

### UC05 � Cancelar Checkin *(�extend�)*
Estende UC02 quando existe um checkin pr�vio pass�vel de cancelamento. Libera a posi��o, incrementa `bikesDisponiveis()` da turma e mant�m o registro hist�rico com `cancelado = true`. Aluno s� cancela o pr�prio checkin enquanto a data n�o passou; professora cancela qualquer checkin a qualquer momento.

### UC06 � Gerenciar Alunos e Grupos
CRUD completo de Aluno e GrupoAlunos. Inclui ativa��o/inativa��o (soft delete). Inativar um aluno cancela automaticamente seus checkins futuros. Grupo com todos os alunos inativos � inativado automaticamente.

### UC07 � Gerenciar Bikes e Fabricantes
CRUD de Bike e Fabricante. Bike � associada a um Fabricante no cadastro. Inativar uma bike cancela seus checkins futuros. Inativar um fabricante n�o inativa as bikes associadas.

### UC08 � Gerenciar Manuten��es
Registro de ocorr�ncias de manuten��o para uma bike espec�fica, com tipo e datas. Ao criar, `atualizarBikesDisponiveis()` � disparado � bike fica indispon�vel. Ao informar `dataRealizacao`, bike volta a estar dispon�vel. Uma bike s� pode ter uma manuten��o pendente por vez.

### UC09 � Cancelar Manuten��o *(�extend�)*
Estende UC08 quando existe uma manuten��o pass�vel de cancelamento. Define `cancelada = true`, dispara `atualizarBikesDisponiveis()` (bike volta a estar dispon�vel) e preserva o registro hist�rico.

### UC10 � Gerenciar Salas e Turmas
CRUD de Sala e Turma. Sala define o layout f�sico (grade fila � coluna) e as posi��es de bikes via PosicaoBike. Turma associa um hor�rio fixo a uma sala. Ao ativar uma turma, `horarioSalaEhLivre()` � sempre verificado.

### UC11 � Verificar Disponibilidade de Hor�rio *(�include�)*
Invocado sempre que UC10 ativa ou edita uma turma. Chama `horarioSalaEhLivre()`, verificando se n�o h� sobreposi��o de dias da semana e hor�rio com outra turma ativa na mesma sala.

### UC12 � Associar Mix � Turma *(�extend�)*
Estende UC10 opcionalmente. Cria um registro TurmaMix com `dataInicio` e `dataFim = null` (mix ativo). Ao associar um novo mix, o TurmaMix anterior tem `dataFim` preenchida. Uma turma pode estar ativa sem mix associado.

### UC13 � Gerenciar Mixes e Repert�rio
CRUD de Mix, Musica, ArtistaBanda, CategoriaMusica e VideoAula. Um mix deve ter ao menos uma m�sica. A mesma m�sica n�o pode aparecer mais de uma vez no mesmo mix. Inativar um mix encerra o TurmaMix ativo associado.

### UC14 � Consultar Agenda Semanal
Exibe todas as turmas ativas em grade semanal (dia � hor�rio) com sala, mix atual e quantidade de bikes dispon�veis em tempo real. Filtro por sala ou dia. Indica��o visual de turmas com alta ocupa��o (= 80%). Corresponde ao Relat�rio R08.

### UC15 � Consultar Mix e Repert�rio
Exibe o mix ativo de cada turma, lista de m�sicas com artista e categorias, links de v�deo-aula e hist�rico dos 3 �ltimos mixes. Corresponde ao Relat�rio R09.

### UC16 � Consultar Hist�rico de Presen�a
Exibe ao aluno seu hist�rico completo de checkins: total, anual e mensal de aulas conclu�das, streak atual e hist�rico, posi��es favoritas por sala. Corresponde aos Relat�rios R06 e R07.

### UC17 � Visualizar Dashboard
Professora: KPIs em tempo real (alunos ativos, aulas agendadas, mixes em uso, bikes OK). Aluno: m�tricas de aulas conclu�das (total, ano, m�s) e aulas agendadas.

### UC18 � Gerar Relat�rios Gerenciais
Acesso aos relat�rios estrat�gicos e gerenciais: R01 (Reten��o), R02 (Sa�de da Frota), R03 (Ocupa��o das Turmas), R04 (Linha do Tempo Musical), R05 (Frequ�ncia por Turma).

---

## Legenda dos Relacionamentos

| Nota��o | Tipo | Sem�ntica |
|---|---|---|
| `------?` `�include�` | Include | UC base **sempre** invoca o UC inclu�do � fluxo obrigat�rio. |
| `- - - -?` `�extend�` | Extend | UC de extens�o **opcionalmente** adiciona comportamento ao UC base � condicional. |
| `-------` | Associa��o | Ator participa do caso de uso. |
