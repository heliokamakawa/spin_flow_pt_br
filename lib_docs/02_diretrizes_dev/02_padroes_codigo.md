# Padr�es de C�digo

## Estrutura de classes Flutter

Ordem recomendada no `State`:
1. atributos
2. `initState` / `didChangeDependencies` / `didUpdateWidget` / `dispose`
3. `build`
4. m�todos privados principais
5. helpers visuais

## Formul�rios

Padr�o m�nimo por formul�rio:
- `_carregarDadosEdicao`
- `_preencherCampos`
- `_limparCampos`
- `_criarDTO`
- `_mostrarMensagem`
- `_redirecionarAposSalvar`
- `_salvar`

Boas pr�ticas:
- usar `mounted` ap�s async
- validar campos obrigat�rios no `Form` e no fluxo de salvar
- manter navega��o consistente (`pop` em edi��o, lista em cria��o)

## Listas

Padr�o m�nimo:
- carregamento async com estado de loading
- estado vazio com CTA
- confirmar exclus�o antes da a��o
- bot�o de refresh no `AppBar`
- recarregar ap�s criar/editar/excluir

## Componentes reutiliz�veis

- nomes claros e descritivos
- callbacks expl�citos (`aoAlterar`, `onChanged`, etc.)
- evitar duplica��o visual em telas

## Conven��es

- portugu�s para nomes de m�todos de neg�cio/UI
- c�digo autoexplicativo (coment�rios apenas quando necess�rio)
- manter padr�o existente do projeto (sem criar arquitetura paralela)
