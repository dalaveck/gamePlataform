// Localidades visitaveis por regiao (minimo 4 por regiao, ver
// prompt-vscode-sistema-3dt.md secao "Mapa do Mundo").
//
// STATUS (Fase 3 do ROADMAP.md, ainda nao iniciada): so as 3 regioes de
// exemplo do prompt original estao preenchidas abaixo. As 38 regioes
// restantes de src/data/mapa/regioes.js ainda precisam de suas localidades
// (tipo comercial | perigo | social | marco | secreto, descricao curta,
// 1-3 ganchos narrativos cada) antes do motor do Mestre poder usa-las.

export const localidades = [
  {
    id: "distrito-neon-mercado-replicas",
    regiaoId: "distrito-neon",
    nome: "Mercado das Replicas",
    tipo: "comercial",
    descricaoBase: "Bancas vendem copias piratas de tudo: roupas de grife, implantes, memorias.",
    ganchosNarrativos: [
      "Um vendedor oferece um implante 'quase original' por um preco bom demais.",
      "Alguem reconhece um item roubado do grupo sendo vendido ali.",
    ],
  },
  {
    id: "distrito-neon-beco-das-apostas",
    regiaoId: "distrito-neon",
    nome: "Beco das Apostas",
    tipo: "perigo",
    descricaoBase: "Jogo ilegal a ceu aberto, disputas que viram briga rapido.",
    ganchosNarrativos: [],
  },
  {
    id: "distrito-neon-terraco-dos-executivos",
    regiaoId: "distrito-neon",
    nome: "Terraco dos Executivos",
    tipo: "social",
    descricaoBase: "Bar suspenso onde gente da corporacao relaxa longe das camaras da diretoria.",
    ganchosNarrativos: [],
  },
  {
    id: "distrito-neon-torre-do-relogio-holografico",
    regiaoId: "distrito-neon",
    nome: "Torre do Relogio Holografico",
    tipo: "marco",
    descricaoBase: "O relogio publico da cidade, projetado a 200 metros de altura.",
    ganchosNarrativos: [],
  },

  {
    id: "favelas-verticais-escadaria-dos-mil-degraus",
    regiaoId: "favelas-verticais",
    nome: "Escadaria dos Mil Degraus",
    tipo: "marco",
    descricaoBase: "Escadaria improvisada que liga o solo ao topo das construcoes empilhadas.",
    ganchosNarrativos: [],
  },
  {
    id: "favelas-verticais-oficina-do-sucateiro-chen",
    regiaoId: "favelas-verticais",
    nome: "Oficina do Sucateiro Chen",
    tipo: "comercial",
    descricaoBase: "Conserta qualquer coisa mecanica, sem perguntar de onde veio.",
    ganchosNarrativos: [],
  },
  {
    id: "favelas-verticais-patio-comunitario",
    regiaoId: "favelas-verticais",
    nome: "Patio Comunitario",
    tipo: "social",
    descricaoBase: "Ponto de encontro do bairro, onde as noticias de rua circulam primeiro.",
    ganchosNarrativos: [],
  },
  {
    id: "favelas-verticais-fiacao-exposta",
    regiaoId: "favelas-verticais",
    nome: "Fiacao Exposta",
    tipo: "perigo",
    descricaoBase: "Trecho de fiacao improvisada e mal isolada, entre os predios empilhados.",
    ganchosNarrativos: [],
  },

  {
    id: "zona-franca-hackers-cafe-criptografado",
    regiaoId: "zona-franca-hackers",
    nome: "Cafe Criptografado",
    tipo: "social",
    descricaoBase: "Ponto de encontro de hackers e ativistas, sem sinal rastreavel.",
    ganchosNarrativos: [],
  },
  {
    id: "zona-franca-hackers-servidor-fantasma",
    regiaoId: "zona-franca-hackers",
    nome: "Servidor Fantasma",
    tipo: "secreto",
    descricaoBase: "Um servidor escondido que ninguem admite administrar.",
    ganchosNarrativos: [],
  },
  {
    id: "zona-franca-hackers-feira-de-hardware-pirata",
    regiaoId: "zona-franca-hackers",
    nome: "Feira de Hardware Pirata",
    tipo: "comercial",
    descricaoBase: "Barracas de componentes eletronicos de origem duvidosa.",
    ganchosNarrativos: [],
  },
  {
    id: "zona-franca-hackers-beco-dos-firewalls-quebrados",
    regiaoId: "zona-franca-hackers",
    nome: "Beco dos Firewalls Quebrados",
    tipo: "perigo",
    descricaoBase: "Territorio disputado por gangues de netrunners rivais.",
    ganchosNarrativos: [],
  },
];

export function localidadesPorRegiao(regiaoId) {
  return localidades.filter((l) => l.regiaoId === regiaoId);
}

export function buscarLocalidade(id) {
  return localidades.find((l) => l.id === id) ?? null;
}
