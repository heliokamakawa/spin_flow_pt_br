# Regras de Dados para Seed

Este arquivo define as regras para criação, revisão e manutenção dos dados iniciais do SpinFlow. O seed deve representar uma academia especializada em spinning, com dados coerentes entre si e úteis para demonstrar os fluxos reais do aplicativo.

## Objetivo

O seed deve permitir testar e demonstrar o app com dados próximos de uma operação real de estúdio de spinning:

- login de professora e aluno;
- agenda de aulas;
- check-in e reserva de bike;
- mapa de sala;
- controle de bikes e manutenção;
- repertório musical usado nas aulas;
- histórico e indicadores.

Os dados devem ser persistidos via SQLite, preferencialmente em `lib/core/database/sqlite/script.dart`, e consumidos pelas camadas de modelo/serviço/DAO do app. Não usar listas mock em runtime.

## Contexto Obrigatório

Todos os dados devem pertencer ao contexto de academia de spinning. Evitar nomes genéricos, escolares, corporativos ou desconectados do domínio.

Contexto-base:

- Academia/estúdio: Pulse Studio Indoor.
- Modalidade principal: spinning ou indoor cycling.
- Operação: aulas coletivas com professora, sala, turma, bike, posição, check-in, fila de espera, manutenção e repertório.
- Linguagem: português do Brasil, com termos naturais para academia.

## Regras Gerais

- Usar nomes plausíveis, mas fictícios quando forem pessoas, e-mails, CPFs, telefones ou contatos.
- Usar fabricantes e marcas compatíveis com equipamentos fitness, bicicletas ergométricas ou indoor cycling.
- Não usar nomes como "Teste", "Mock", "Demo", "Exemplo", "Lorem", "Foo", "Bar" em dados exibidos no app.
- Não usar dados fora do domínio, como escolas, escritórios, restaurantes, produtos aleatórios ou eventos sem relação com spinning.
- Manter relações consistentes: bike deve ter fabricante; turma deve ter sala; check-in deve apontar para aluno/turma/data/posição válida; manutenção deve apontar para bike e tipo de manutenção.
- Manter alguns dados inativos para testar exclusão lógica, mas eles também devem ser plausíveis.
- Dados dinâmicos dependentes de data devem usar `DateTime.now()` apenas quando necessário para testar aulas de hoje, amanhã, janela de reserva, lotação e histórico.
- Evitar seed excessivo. O volume deve cobrir cenários importantes sem poluir telas.

## Entidades e Padrões

### Usuários

Usuários do seed devem permitir login real pelo banco SQLite.

Perfis mínimos:

- Professora ativa: `professora`.
- Aluno ativo: `aluno`.

Regras:

- E-mail deve coincidir com aluno/professora quando houver entidade relacionada.
- CPF deve ser fictício, numérico e único.
- Senha do seed pode ser simples para ambiente acadêmico/demonstração, mas deve estar documentada nos testes.
- O login deve autenticar por e-mail e CPF.

Exemplos de nomes:

- Ana Beatriz, Mariana Torres, Paula Nogueira, Camila Rocha.
- Carlos Almeida, Juliana Martins, Roberto Gomes, Fernanda Lima.

### Alunos

Alunos devem parecer frequentadores reais de uma academia.

Regras:

- Usar nomes brasileiros plausíveis.
- Manter pelo menos 20 alunos ativos para teste de volume.
- Separar os alunos por nível de uso: 10 de uso intenso, 5 iniciantes e 5 medianos.
- Alunos de uso intenso devem ter histórico de participação mais forte, com pelo menos 6 check-ins/aulas por aluno no seed.
- Alunos iniciantes devem ter pelo menos 2 check-ins/aulas por aluno no seed.
- Alunos medianos devem ter pelo menos 3 check-ins/aulas por aluno no seed.
- Ter gêneros, telefones e datas de nascimento coerentes.
- Observações devem falar de frequência, preferência de horário, nível, restrição ou comportamento de aula.
- Manter pelo menos um aluno ativo usado no login.
- Manter pelo menos um aluno inativo para validar filtros e exclusão lógica.

Exemplos de observações:

- "Preferência por aulas cedo."
- "Aluna avançada, costuma reservar primeira fileira."
- "Aluno em retorno gradual aos treinos."
- "Alta frequência nas turmas da noite."

### Professoras

Quando houver professoras como usuários ou futuras entidades, o contexto deve ser de instrutoras de spinning.

Regras:

- Usar perfil `professora`.
- Associar nomes a aulas e operações de sala quando o modelo permitir.
- Evitar títulos genéricos como "Admin" ou "Professor Teste".

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

- Descrição deve citar equipamento fitness, indoor cycling, bike de spinning, resistência magnética, manutenção ou uso em estúdios.
- Contatos devem ser plausíveis e relacionados a suporte, vendas ou assistência técnica.
- Não cadastrar fabricantes de itens sem relação com spinning.

### Bikes

Bikes representam equipamentos físicos do estúdio.

Regras:

- Nomear de forma operacional: "Bike 01", "Bike 02", "Sprint 01", "Climb 03", "Studio Bike 12".
- Número de série deve ser único e padronizado.
- Toda bike deve apontar para um fabricante existente.
- Deve haver bikes suficientes para preencher as salas cadastradas.
- Algumas bikes podem estar inativas ou em manutenção para testar indisponibilidade.

Exemplos de números de série:

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

- Definir quantidade de filas e colunas compatível com bikes.
- Manter 2 salas principais para teste.
- Cada sala de teste deve ter 3 filas de bikes.
- Cada sala deve ter pelo menos 15 bikes reserváveis para alunos.
- A posição da professora deve ficar fora das posições reserváveis pelos alunos.
- Pelo menos uma sala deve ter mapa suficiente para testar lotação.

### Posições de Bike

Posições devem formar o mapa real da sala.

Regras:

- Cada posição deve ter fila e coluna válidas.
- Não duplicar bike na mesma posição.
- Não posicionar bike na posição da professora.
- Deve haver posições livres, ocupadas, reservadas pelo aluno e bloqueadas por manutenção nos cenários de teste.

### Turmas

Turmas são aulas recorrentes de spinning.

Exemplos de nomes:

- Power Ride 07h.
- Sprint HIIT.
- Climb Endurance.
- Rhythm Ride.
- Spin Burn.
- Cadência Base.
- Ride Recovery.

Regras:

- Nome deve indicar estilo, intensidade ou horário da aula.
- Descrição deve mencionar foco da aula: cadência, força, sprint, resistência, técnica, recuperação.
- Dias da semana devem ser coerentes com agenda.
- Horários devem permitir cenários de check-in: aula futura, aula dentro da janela de 30 minutos, aula encerrada, aula lotada.
- Duração típica: 45, 50 ou 60 minutos.
- Toda turma ativa deve ter sala ativa.

### Check-ins

Check-ins representam reservas reais de alunos em turmas.

Regras:

- Check-in ativo deve apontar para aluno ativo, turma ativa e posição válida.
- Não criar dois check-ins ativos para a mesma posição/turma/data.
- Criar cenários mínimos:
  - aluno logado já reservado;
  - turma com vagas;
  - turma lotada;
  - fila de espera;
  - histórico de aula passada;
  - reserva cancelada/inativa.
- Datas devem ser dinâmicas quando o fluxo depende de "hoje".

### Fila de Espera

Fila deve existir apenas para turma lotada ou cenário de indisponibilidade.

Regras:

- Aluno na fila deve estar ativo.
- Fila ativa deve apontar para turma/data plausíveis.
- Registrar `criado_em` com horário anterior à aula.

### Manutenções

Manutenções devem refletir problemas típicos de bike de spinning.

Tipos adequados:

- Pedal quebrado.
- Regulagem de altura.
- Banco com problema.
- Correia de transmissão.
- Resistência com defeito.
- Ruído no volante.
- Sensor de cadência.
- Aperto de guidão.

Regras:

- Manutenção ativa deve deixar a bike indisponível no mapa/check-in.
- Estado operacional deve ser claro: pendente, em andamento, resolvida, cancelada.
- Descrição deve parecer uma ocorrência real de sala.

### Repertório Musical

O repertório deve apoiar aulas de spinning, com músicas, categorias, artistas/bandas, mix e videoaulas.

Categorias adequadas:

- Aquecimento.
- Cadência.
- Ritmo.
- Sprint.
- Subida.
- Força.
- Resistência.
- Recuperação.
- Alongamento.

Regras:

- Músicas devem ter função dentro da aula.
- Mix deve ter ordem coerente: aquecimento, blocos principais, pico, recuperação.
- Todo mix usado no seed deve ter pelo menos 10 faixas.
- Videoaulas devem orientar execução no spinning, não serem vídeos genéricos.
- Artistas/bandas podem ser reais ou fictícios, mas o uso deve ser coerente com treino.

Exemplos de nomes fictícios de músicas:

- Warm Wheels.
- Ride the Fire.
- Climb Higher.
- Pulse Sprint.
- Deep Resistance.
- Final Push.
- Cool Down Flow.

### Grupos de Alunos

Grupos devem representar agrupamentos úteis para a operação.

Exemplos:

- Manhã Alta Frequência.
- Iniciantes 07h.
- Sprint Avançado.
- Recuperação e Técnica.
- Noite Endurance.

Regras:

- Grupo deve ter descrição com objetivo operacional.
- Associar alunos ativos.
- Evitar grupos sem uso ou com nomes genéricos.

## Cenários Mínimos do Seed

O seed deve cobrir, no mínimo:

1. Login de professora por e-mail.
2. Login de aluno por e-mail.
3. Login de aluno por CPF.
4. Cadastro de pelo menos 20 alunos ativos: 10 de uso intenso, 5 iniciantes e 5 medianos.
5. Histórico de aulas/check-ins coerente com o nível de uso de cada aluno.
6. Cadastro de professoras, turmas, salas, bikes, fabricantes, repertório, artistas/bandas, músicas e mixes.
7. Duas salas de teste, cada uma com 3 filas e pelo menos 15 bikes reserváveis.
8. Todo mix com pelo menos 10 músicas.
9. Dashboard do aluno com aula de hoje e reserva ativa.
10. Check-in com turma disponível.
11. Check-in com turma lotada e fila de espera.
12. Mapa de aula com posições livres, ocupadas, minha reserva, professora e manutenção.
13. Dashboard da professora com aulas, repertório e administrativo.
14. CRUD administrativo com dados reais de sala, turma, manutenção e grupo.
15. Repertório com mix completo para uma aula.
16. Histórico do aluno com aula passada.

## Proibições

Não usar no seed:

- `mock`, `teste`, `dummy`, `sample`, `lorem`, `foo`, `bar` em nomes exibidos.
- Dados de escola, loja, escritório ou domínio sem relação com spinning.
- Fabricantes aleatórios de tecnologia, alimentos ou roupas sem vínculo fitness.
- Salas chamadas apenas "Sala 1" quando o nome aparece para o usuário.
- Turmas chamadas apenas "Turma A" ou "Aula Teste".
- Músicas sem função no treino.
- Check-ins sem aluno/turma/posição válidos.

## Critérios de Aceite

Antes de considerar o seed pronto:

- `rg -n "mock|dummy|sample|lorem|foo|bar|teste" lib/core/database/sqlite/script.dart` não deve encontrar dados exibidos ao usuário.
- Login deve passar por `DAOUsuarioSQLite`.
- O app não deve importar `lib/excluir/banco/mock` em nenhuma tela, controller, serviço ou DAO ativo.
- Os dados devem abrir telas principais sem listas vazias inesperadas.
- O fluxo de reserva/cancelamento deve alterar dados no SQLite.
- As entidades novas devem usar modelos (`Modelo...`) e DAOs SQLite da camada `lib/model/dao/sqlite` sempre que já existirem.
