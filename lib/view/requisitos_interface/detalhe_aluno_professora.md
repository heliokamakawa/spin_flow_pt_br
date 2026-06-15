# Detalhe do Aluno (visão da professora)

## Localização
Acessado a partir de PainelFrequenciaProfessora ao tocar em um aluno da lista.

## Carregamento
- Ao abrir, carrega dados do Aluno e lista de turmas frequentadas com esta professora.
- Exibe CircularProgressIndicator durante o carregamento.
- Erro de carregamento: mensagem + botão "Tentar novamente".

## Seção: Dados do aluno
Card com os campos abaixo. Valor ausente ou vazio exibe "—".
- Nome (destaque, fontSize maior)
- Data de nascimento (formato dd/MM/yyyy)
- Gênero (Masculino / Feminino / Outro)
- Telefone
- E-mail
- Instagram
- Facebook
- TikTok
- Observações

## Seção: Turmas frequentadas com esta professora
Card separado, abaixo dos dados do aluno.
- Título da seção: "Turmas frequentadas"
- Lista das turmas distintas onde o aluno tem check-ins ativos com esta professora.
- Cada item mostra: nome da turma, horário de início e total de check-ins nessa turma.
- Ordenado por horário de início (crescente).
- Sem turmas: "Nenhuma turma registrada."
