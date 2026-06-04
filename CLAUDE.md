# SpinFlow — Instruções para Claude

Projeto Flutter didático de indoor cycling em português (PT-BR).
Usado em aula de Engenharia de Software.

---

## Convenções obrigatórias

- **Nomes em português** — classes, métodos, variáveis, arquivos.
- Organização por domínio: `domain/`, `infra/`, `controller/`, `view/`.
- Sem repositório explícito — o repositório fica dentro de `infra/database/repositorio/`.
- `get_it` é usado **somente para DAOs** (ponto de variância de tecnologia). Repositórios, controllers e views instanciam dependências diretamente — sem `get_it`.
- Antes de implementar qualquer entidade ou regra, ler `docs/dc.md`.
- Requisitos de tela ficam em `lib/view/requisitos_interface/<nome_da_tela>.md`.

---

## Onde corrigir cada tipo de problema

Quando o PO indicar um erro ou solicitar uma correção, identificar a camada correta
antes de qualquer alteração:

| Tipo de problema | Onde corrigir |
|---|---|
| Regra de negócio (cálculo, validação, restrição, estado) | `lib/domain/dominio/` ou `lib/domain/modelo/` |
| Estrutura ou semântica de dados (campos, tipos, relacionamentos) | `lib/domain/modelo/` |
| Acesso a dados, queries, persistência | `lib/infra/database/` |
| Comportamento ou layout de tela | `lib/view/` **e** o MD correspondente em `lib/view/requisitos_interface/` |

**Nunca corrigir apenas uma camada quando o problema atravessa mais de uma.**
Ex.: erro de cálculo que aparece na tela deve ser corrigido no domínio/modelo *e*
o MD de requisitos deve ser atualizado para refletir a regra correta.

---

## Protocolo para implementação de telas

Toda implementação ou alteração de tela **obrigatoriamente**:

1. **Ler** o arquivo `lib/view/requisitos_interface/<nome_da_tela>.md` antes de qualquer código.
2. **Obedecer** todas as regras, layouts e comportamentos descritos no MD.
3. **Atualizar** o MD quando:
   - O PO indicar um novo comportamento ou regra.
   - Um erro for corrigido e a regra mudar.
   - Uma nova funcionalidade for adicionada à tela.
4. O MD é a **fonte da verdade** da tela — o código deve espelhar o MD, não o contrário.

Se não existir MD para a tela, criar antes de implementar usando o template:
```
lib/view/requisitos_interface/<nome_exato_do_arquivo_dart>.md
```

---

## ⚠️ Regras de check-in — VALIDADAS E ESTÁVEIS

As regras abaixo foram implementadas e validadas pelo PO. **Não alterar sem instrução explícita.**

### Cálculo de capacidade (`SituacaoCheckinAluno` + `listarTurmasHoje`)
- `totalBikes` = capacidade **efetiva** = posições sem professora e sem manutenção.
- `bikesEmManutencao` = campo informativo separado (não entra no denominador).
- `vagasDisponiveis` = `totalBikes − checkinsNaTurma.length`.
- `textoOcupacao` = `'$vagasOcupadas/$totalBikes'` (check-ins sobre capacidade efetiva).

### Status e prioridade (`StatusCheckinAluno`)
Ordem de avaliação no repositório (maior prioridade primeiro):
1. `confirmado` — aluno já tem check-in nesta turma.
2. `emFila` — aluno está na fila de espera.
3. `conflito` — tem check-in ativo em turma **sobreponente** (não adjacente).
4. `lotada` — vagas == 0.
5. `janelaFechada` — janela abre 30 min antes.
6. `disponivel` — tudo OK.

### Regra de conflito (`sobrepoeHorario`)
Usa interseção estrita de intervalos. **Turmas adjacentes NÃO conflitam.**
Ex.: Turma A 15:00–15:50 e Turma B 15:51–16:41 são consecutivas e permitidas.

### Ações após operação bem-sucedida
- Check-in confirmado → `Navigator.pop()` (volta à lista).
- Entrou na fila → `Navigator.pop()` (volta à lista).
- Cancelou check-in → `_carregar()` (permanece no mapa).
- Saiu da fila → `_carregar()` (permanece no mapa).

### Regra de limpeza de fila
Ao fazer check-in em uma turma, o sistema remove automaticamente o aluno
da fila de espera dessa mesma turma (caso exista registro ativo).
Implementado em `RepositorioCheckinAluno.reservar`.

### Botão da lista de aulas (`tela_dashboard_checkin.dart`)
| Status        | Label             | Ativo | Cor     |
|---------------|-------------------|-------|---------|
| disponivel    | Check-in          | sim   | sucesso |
| lotada        | Entrar na Fila    | sim   | alerta  |
| confirmado    | Cancelar Check-in | sim   | erro    |
| janelaFechada | Aguardando        | não   | cinza   |
| emFila        | Na Fila · #N      | não   | cinza   |
| conflito      | Conflito de Horário | não | cinza   |

---

## Documentação de referência

- Diagrama de classes: `docs/dc.md`
- Requisitos de tela: `lib/view/requisitos_interface/`
  - `tela_dashboard_checkin.md` — dashboard do aluno (check-in + painel)
  - `tela_checkin.md` — mapa de bikes e check-in
