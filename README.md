# Imersivo Vibe Code - Landing Page

Landing page estática para venda do **Imersivo Vibe Code**, evento presencial da **INEMA** em Canela/RS.

URL de produção na Vercel: https://imersaovc.vercel.app/

## Estrutura

- `index.html`: página principal publicada.
- `assets/css/imersivo-vibe-code.css`: estilos da landing.
- `assets/js/event-config.js`: configuração central de evento, checkout, SEO, FAQs, projetos e depoimentos.
- `assets/js/main.js`: comportamento da página, CTAs, FAQ, analytics neutro e renderização condicional de provas.
- `assets/hero-vibe-coding.png`: imagem visual abstrata utilizada no hero.
- `assets/social/`: criativos sociais gerados pelo script.
- `scripts/generate-social-assets.ps1`: gera imagens sociais com as informações atuais do evento.

## Publicação na Vercel

Projeto estático, sem build.

Configuração recomendada:

- Framework Preset: **Other**
- Build Command: deixar vazio
- Output Directory: `.`
- Install Command: deixar vazio

## Conteúdo editável

As informações variáveis ficam em `assets/js/event-config.js`.

Para ativar o checkout, substitua:

```js
const CHECKOUT_URL = "#";
```

pelo link final gerado no Asaas.

## Pendências intencionais

- TODO: adicionar checkout do Asaas.
- TODO: adicionar imagens reais.
- TODO: adicionar projetos reais.
- TODO: adicionar depoimentos reais.
- TODO: confirmar URL canônica.
- TODO: adicionar imagem de compartilhamento final, caso a atual seja substituída.

Os arquivos `versao-1.html` a `versao-4.html` permanecem apenas como referência histórica da landing anterior e não são usados pela página principal. No Vercel, essas rotas são redirecionadas para `/` em `vercel.json`.
