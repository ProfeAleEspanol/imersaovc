// Configuração central da página Imersivo Vibe Code.
// TODO: adicionar checkout do Asaas
const CHECKOUT_URL = "#";

window.IVC_CONFIG = {
  eventName: "Imersivo Vibe Code",
  organization: "INEMA",
  dates: {
    label: "28, 29 e 30 de agosto de 2026",
    shortLabel: "28 a 30 de agosto de 2026",
    startDate: "2026-08-28",
    endDate: "2026-08-30"
  },
  city: "Canela/RS",
  venue: "Refúgio INEMA",
  format: "Presencial",
  workload: "30 horas",
  seats: 10,
  price: "R$ 2.497",
  installmentCondition: "",
  checkoutUrl: CHECKOUT_URL,
  // TODO: adicionar URL do WhatsApp, se for utilizada futuramente.
  whatsappUrl: "",
  seo: {
    title: "Imersivo Vibe Code em Canela | INEMA",
    description: "Transforme sua ideia em uma primeira versão funcional e publicada em três dias de construção presencial com inteligência artificial. 28 a 30 de agosto de 2026, em Canela/RS.",
    // TODO: confirmar URL canônica
    canonicalUrl: "https://inematds.github.io/imersaovc/",
    // TODO: adicionar imagem de compartilhamento
    socialImage: "https://inematds.github.io/imersaovc/assets/social/linkedin-feed-1200x627.png"
  },
  images: {
    hero: "assets/hero-vibe-coding.png"
    // TODO: adicionar imagens reais
  },
  socials: {},
  faqs: [
    {
      question: "Preciso saber programar?",
      answer: "Não. A imersão foi estruturada para que você utilize inteligência artificial durante a construção. Ter familiaridade com computadores ajuda, mas não é necessário chegar com experiência em programação."
    },
    {
      question: "Preciso chegar com uma ideia completamente pronta?",
      answer: "Não. Você pode chegar com uma ideia inicial, um problema, um processo manual ou um projeto que ainda não conseguiu concluir. O escopo será organizado para a construção da primeira versão."
    },
    {
      question: "Qualquer projeto pode ser concluído em três dias?",
      answer: "Projetos muito amplos precisarão ser reduzidos. O objetivo é desenvolver e publicar uma primeira versão funcional, com escopo compatível com o tempo da imersão."
    },
    {
      question: "Quais ferramentas serão utilizadas?",
      answer: "O Vibe Code é a abordagem central. Poderemos combinar Codex, Claude, GitHub, Vercel e outras ferramentas conforme as necessidades de cada projeto."
    },
    {
      question: "O evento é presencial?",
      answer: "Sim. O Imersivo será realizado presencialmente no Refúgio INEMA, em Canela/RS."
    },
    {
      question: "Quando acontecerá?",
      answer: "Nos dias 28, 29 e 30 de agosto de 2026."
    },
    {
      question: "Quantas vagas estão disponíveis?",
      answer: "A turma terá somente dez participantes, devido ao acompanhamento necessário durante a construção de cada projeto."
    },
    {
      question: "Qual é o investimento?",
      answer: "R$ 2.497."
    }
  ],
  // TODO: adicionar projetos reais
  // Estrutura esperada:
  // {
  //   participantName: "Nome real do participante",
  //   photo: "assets/projetos/foto-real.jpg",
  //   screenshot: "assets/projetos/captura-real.jpg",
  //   initialProblem: "Ideia ou problema inicial real",
  //   built: "O que foi construído",
  //   stage: "Estágio atingido",
  //   testimonial: "Depoimento curto real",
  //   url: "https://url-real-do-projeto.com"
  // }
  projects: [],
  // TODO: adicionar depoimentos reais
  testimonials: []
};
