# Regras de Dados para Seed

Este arquivo define as regras para cria��o, revis�o e manuten��o dos dados iniciais do SpinFlow. O seed deve representar uma academia especializada em spinning, com dados coerentes entre si e �teis para demonstrar os fluxos reais do aplicativo.

## Objetivo

O seed deve permitir testar e demonstrar o app com dados pr�ximos de uma opera��o real de est�dio de spinning:

- login de professora e aluno;
- agenda de aulas;
- check-in e reserva de bike;
- mapa de sala;
- controle de bikes e manuten��o;
- repert�rio musical usado nas aulas;
- hist�rico e indicadores.

Os dados devem ser persistidos via SQLite, preferencialmente em `lib/database/sqlite/script.dart`, e consumidos pelas camadas de modelo/servi�o/DAO do app. N�o usar listas mock em runtime.

## Contexto Obrigat�rio

Todos os dados devem pertencer ao contexto de academia de spinning. Evitar nomes gen�ricos, escolares, corporativos ou desconectados do dom�nio.

Contexto-base:

- Academia/est�dio: Pulse Studio Indoor.
- Modalidade principal: spinning ou indoor cycling.
- Opera��o: aulas coletivas com professora, sala, turma, bike, posi��o, check-in, fila de espera, manuten��o e repert�rio.
- Linguagem: portugu�s do Brasil, com termos naturais para academia.

## Regras Gerais

- Usar nomes plaus�veis, mas fict�cios quando forem pessoas, e-mails, CPFs, telefones ou contatos.
- Usar fabricantes e marcas compat�veis com equipamentos fitness, bicicletas ergom�tricas ou indoor cycling.
- N�o usar nomes como "Teste", "Mock", "Demo", "Exemplo", "Lorem", "Foo", "Bar" em dados exibidos no app.
- N�o usar dados fora do dom�nio, como escolas, escrit�rios, restaurantes, produtos aleat�rios ou eventos sem rela��o com spinning.
- Manter rela��es consistentes: bike deve ter fabricante; turma deve ter sala; check-in deve apontar para aluno/turma/data/posi��o v�lida; manuten��o deve apontar para bike e tipo de manuten��o.
- Manter alguns dados inativos para testar exclus�o l�gica, mas eles tamb�m devem ser plaus�veis.
- Dados din�micos dependentes de data devem usar `DateTime.now()` apenas quando necess�rio para testar aulas de hoje, amanh�, janela de reserva, lota��o e hist�rico.
- Evitar seed excessivo. O volume deve cobrir cen�rios importantes sem poluir telas.

## Entidades e Padr�es

### Usu�rios

Usu�rios do seed devem permitir login real pelo banco SQLite.

Perfis m�nimos:

- Professora ativa: `professora`.
- Aluno ativo: `aluno`.

Regras:

- E-mail deve coincidir com aluno/professora quando houver entidade relacionada.
- CPF deve ser fict�cio, num�rico e �nico.
- Senha do seed pode ser simples para ambiente acad�mico/demonstra��o, mas deve estar documentada nos testes.
- O login deve autenticar por e-mail e CPF.

Exemplos de nomes:

- Ana Beatriz, Mariana Torres, Paula Nogueira, Camila Rocha.
- Carlos Almeida, Juliana Martins, Roberto Gomes, Fernanda Lima.

### Alunos

Alunos devem parecer frequentadores reais de uma academia.

Regras:

- Usar nomes brasileiros plaus�veis.
- Manter pelo menos 20 alunos ativos para teste de volume.
- Separar os alunos por n�vel de uso: 10 de uso intenso, 5 iniciantes e 5 medianos.
- Alunos de uso intenso devem ter hist�rico de participa��o mais forte, com pelo menos 6 check-ins/aulas por aluno no seed.
- Alunos iniciantes devem ter pelo menos 2 check-ins/aulas por aluno no seed.
- Alunos medianos devem ter pelo menos 3 check-ins/aulas por aluno no seed.
- Ter g�neros, telefones e datas de nascimento coerentes.
- Observa��es devem falar de frequ�ncia, prefer�ncia de hor�rio, n�vel, restri��o ou comportamento de aula.
- Manter pelo menos um aluno ativo usado no login.
- Manter pelo menos um aluno inativo para validar filtros e exclus�o l�gica.

Exemplos de observa��es:

- "Prefer�ncia por aulas cedo."
- "Aluna avan�ada, costuma reservar primeira fileira."
- "Aluno em retorno gradual aos treinos."
- "Alta frequ�ncia nas turmas da noite."

### Professoras

Quando houver professoras como usu�rios ou futuras entidades, o contexto deve ser de instrutoras de spinning.

Regras:

- Usar perfil `professora`.
- Associar nomes a aulas e opera��es de sala quando o modelo permitir.
- Evitar t�tulos gen�ricos como "Admin" ou "Professor Teste".

### Fabricantes

Fabricantes devem ser do mercado fitness, bikes de spinning ou equipamentos de academia.

Exemplos adequados:

- Technogym.
- Movement.
- Schwinn Fitness.
- Keiser.
- Stages Cycling.
- Life Fitness.
- Matrix Fitness.
- Reebok Fitness.

Regras:

- Descri��o deve citar equipamento fitness, indoor cycling, bike de spinning, resist�ncia magn�tica, manuten��o ou uso em est�dios.
- Contatos devem ser plaus�veis e relacionados a suporte, vendas ou assist�ncia t�cnica.
- N�o cadastrar fabricantes de itens sem rela��o com spinning.

### Bikes

Bikes representam equipamentos f�sicos do est�dio.

Regras:

- Nomear de forma operacional: "Bike 01", "Bike 02", "Sprint 01", "Climb 03", "Studio Bike 12".
- N�mero de s�rie deve ser �nico e padronizado.
- Toda bike deve apontar para um fabricante existente.
- Deve haver bikes suficientes para preencher as salas cadastradas.
- Algumas bikes podem estar inativas ou em manuten��o para testar indisponibilidade.

Exemplos de n�meros de s�rie:

- `PSI-BK-0001`.
- `MOVE-RIDE-0012`.
- `SPIN-STUDIO-042`.

### Salas

Salas devem representar ambientes de spinning.

Exemplos:

- Studio Ride.
- Sala Sprint.
- Studio Endurance.
- Studio Sprint.

Regras:

- Definir quantidade de filas e colunas compat�vel com bikes.
- Manter 2 salas principais para teste.
- Cada sala de teste deve ter 3 filas de bikes.
- Cada sala deve ter pelo menos 15 bikes reserv�veis para alunos.
- A posi��o da professora deve ficar fora das posi��es reserv�veis pelos alunos.
- Pelo menos uma sala deve ter mapa suficiente para testar lota��o.

### Posi��es de Bike

Posi��es devem formar o mapa real da sala.

Regras:

- Cada posi��o deve ter fila e coluna v�lidas.
- N�o duplicar bike na mesma posi��o.
- N�o posicionar bike na posi��o da professora.
- Deve haver posi��es livres, ocupadas, reservadas pelo aluno e bloqueadas por manuten��o nos cen�rios de teste.

### Turmas

Turmas s�o aulas recorrentes de spinning.

Exemplos de nomes:

- Power Ride 07h.
- Sprint HIIT.
- Climb Endurance.
- Rhythm Ride.
- Spin Burn.
- Cad�ncia Base.
- Ride Recovery.

Regras:

- Nome deve indicar estilo, intensidade ou hor�rio da aula.
- Descri��o deve mencionar foco da aula: cad�ncia, for�a, sprint, resist�ncia, t�cnica, recupera��o.
- Dias da semana devem ser coerentes com agenda.
- Hor�rios devem permitir cen�rios de check-in: aula futura, aula dentro da janela de 30 minutos, aula encerrada, aula lotada.
- Dura��o t�pica: 45, 50 ou 60 minutos.
- Toda turma ativa deve ter sala ativa.

### Check-ins

Check-ins representam reservas reais de alunos em turmas.

Regras:

- Check-in ativo deve apontar para aluno ativo, turma ativa e posi��o v�lida.
- N�o criar dois check-ins ativos para a mesma posi��o/turma/data.
- Criar cen�rios m�nimos:
  - aluno logado j� reservado;
  - turma com vagas;
  - turma lotada;
  - fila de espera;
  - hist�rico de aula passada;
  - reserva cancelada/inativa.
- Datas devem ser din�micas quando o fluxo depende de "hoje".

### Fila de Espera

Fila deve existir apenas para turma lotada ou cen�rio de indisponibilidade.

Regras:

- Aluno na fila deve estar ativo.
- Fila ativa deve apontar para turma/data plaus�veis.
- Registrar `criado_em` com hor�rio anterior � aula.

### Manuten��es

Manuten��es devem refletir problemas t�picos de bike de spinning.

Tipos adequados:

- Pedal quebrado.
- Regulagem de altura.
- Banco com problema.
- Correia de transmiss�o.
- Resist�ncia com defeito.
- Ru�do no volante.
- Sensor de cad�ncia.
- Aperto de guid�o.

Regras:

- Manuten��o ativa deve deixar a bike indispon�vel no mapa/check-in.
- Estado operacional deve ser claro: pendente, em andamento, resolvida, cancelada.
- Descri��o deve parecer uma ocorr�ncia real de sala.

### Repert�rio Musical

O repert�rio deve apoiar aulas de spinning, com m�sicas, categorias, artistas/bandas, mix e videoaulas.

Categorias adequadas:

- Aquecimento.
- Cad�ncia.
- Ritmo.
- Sprint.
- Subida.
- For�a.
- Resist�ncia.
- Recupera��o.
- Alongamento.

Regras:

- M�sicas devem ter fun��o dentro da aula.
- Mix deve ter ordem coerente: aquecimento, blocos principais, pico, recupera��o.
- Todo mix usado no seed deve ter pelo menos 10 faixas.
- Videoaulas devem orientar execu��o no spinning, n�o serem v�deos gen�ricos.
- Artistas/bandas podem ser reais ou fict�cios, mas o uso deve ser coerente com treino.

Exemplos de nomes fict�cios de m�sicas:

- Warm Wheels.
- Ride the Fire.
- Climb Higher.
- Pulse Sprint.
- Deep Resistance.
- Final Push.
- Cool Down Flow.

### Grupos de Alunos

Grupos devem representar agrupamentos �teis para a opera��o.

Exemplos:

- Manh� Alta Frequ�ncia.
- Iniciantes 07h.
- Sprint Avan�ado.
- Recupera��o e T�cnica.
- Noite Endurance.

Regras:

- Grupo deve ter descri��o com objetivo operacional.
- Associar alunos ativos.
- Evitar grupos sem uso ou com nomes gen�ricos.

## Cen�rios M�nimos do Seed

O seed deve cobrir, no m�nimo:

1. Login de professora por e-mail.
2. Login de aluno por e-mail.
3. Login de aluno por CPF.
4. Cadastro de pelo menos 20 alunos ativos: 10 de uso intenso, 5 iniciantes e 5 medianos.
5. Hist�rico de aulas/check-ins coerente com o n�vel de uso de cada aluno.
6. Cadastro de professoras, turmas, salas, bikes, fabricantes, repert�rio, artistas/bandas, m�sicas e mixes.
7. Duas salas de teste, cada uma com 3 filas e pelo menos 15 bikes reserv�veis.
8. Todo mix com pelo menos 10 m�sicas.
9. Dashboard do aluno com aula de hoje e reserva ativa.
10. Check-in com turma dispon�vel.
11. Check-in com turma lotada e fila de espera.
12. Mapa de aula com posi��es livres, ocupadas, minha reserva, professora e manuten��o.
13. Dashboard da professora com aulas, repert�rio e administrativo.
14. CRUD administrativo com dados reais de sala, turma, manuten��o e grupo.
15. Repert�rio com mix completo para uma aula.
16. Hist�rico do aluno com aula passada.

## Proibi��es

N�o usar no seed:

- `mock`, `teste`, `dummy`, `sample`, `lorem`, `foo`, `bar` em nomes exibidos.
- Dados de escola, loja, escrit�rio ou dom�nio sem rela��o com spinning.
- Fabricantes aleat�rios de tecnologia, alimentos ou roupas sem v�nculo fitness.
- Salas chamadas apenas "Sala 1" quando o nome aparece para o usu�rio.
- Turmas chamadas apenas "Turma A" ou "Aula Teste".
- M�sicas sem fun��o no treino.
- Check-ins sem aluno/turma/posi��o v�lidos.

## Crit�rios de Aceite

Antes de considerar o seed pronto:

- `rg -n "mock|dummy|sample|lorem|foo|bar|teste" lib/database/sqlite/script.dart` n�o deve encontrar dados exibidos ao usu�rio.
- Login deve passar por `DAOUsuarioSQLite`.
- O app n�o deve importar `lib/excluir/banco/mock` em nenhuma tela, controller, servi�o ou DAO ativo.
- Os dados devem abrir telas principais sem listas vazias inesperadas.
- O fluxo de reserva/cancelamento deve alterar dados no SQLite.
- As entidades novas devem usar modelos (`Modelo...`) e DAOs SQLite da camada `lib/database/sqlite/dao` sempre que j� existirem.
