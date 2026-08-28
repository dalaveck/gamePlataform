// Vantagens — custam pontos, mas nao sao poderes acionados (sem custo em PA).
// Fonte: material/habilidades-3dt-cyberpunk.html.

export const vantagens = [
  {
    id: "ferro-de-estimacao",
    nome: "Ferro de estimacao",
    custoPontos: 1,
    efeito: "+1 na FA alem do bonus normal do equipamento, para uma arma especifica e sua.",
    descricao:
      "Uma arma especifica e sua, com historia. Some +1 na FA alem do bonus normal do equipamento. Se for perdida ou destruida, o bonus so volta quando voce a recuperar ou reconstruir — e isso vira cena.",
  },
  {
    id: "territorio",
    nome: "Territorio",
    custoPontos: 1,
    efeito: "+2 em Habilidade dentro de um bairro/predio/setor especifico onde voce manda.",
    descricao:
      "Um bairro, predio ou setor onde voce manda. Ali voce tem +2 em Habilidade, sabe todas as saidas e ninguem entra sem voce ficar sabendo. Escolha algo especifico — nao vale \"a cidade\".",
  },
  {
    id: "grana-velha",
    nome: "Grana velha",
    custoPontos: 2,
    efeito: "Compra um item ou servico razoavel sem discussao de preco a cada sessao.",
    descricao:
      "Voce tem conta gorda e credito limpo. Comeca cada sessao podendo comprar um item ou servico razoavel sem discussao de preco. Nao cobre armamento pesado nem suborno de gente grauda.",
  },
  {
    id: "identidade-falsa",
    nome: "Identidade falsa",
    custoPontos: 1,
    efeito: "Passa por qualquer checagem de rotina; queima se investigada a fundo.",
    descricao:
      "Um rosto legal, registrado, com historico de emprego e ficha limpa. Passa por qualquer checagem de rotina. Queima se for investigada a fundo, e ai voce precisa de outra.",
  },
  {
    id: "aliado",
    nome: "Aliado",
    custoPontos: 2,
    efeito: "Um NPC leal com cerca de 5 pontos, disponivel quando voce chamar.",
    descricao:
      "Um NPC leal de verdade — um ripperdoc, um fixer, um irmao. Tem por volta de 5 pontos e aparece quando voce chamar, mas tem vida, medo e agenda propria.",
  },
  {
    id: "sentidos-ampliados",
    nome: "Sentidos ampliados",
    custoPontos: 1,
    efeito: "+2 em testes de Investigacao ligados a um sentido escolhido; ignora penalidades relacionadas.",
    descricao:
      "Escolha um: audicao, olfato, visao termica ou infravermelha. Some +2 em testes de Investigacao ligados a ele e ignore as penalidades relacionadas.",
  },
  {
    id: "reputacao",
    nome: "Reputacao",
    custoPontos: 1,
    efeito: "+2 em Manipulacao com quem ja ouviu falar de voce; tambem te torna reconhecivel.",
    descricao:
      "Seu nome corre nas ruas. +2 em Manipulacao com quem ja ouviu falar de voce — o que tambem significa que testemunhas sabem exatamente quem procurar depois.",
  },
  {
    id: "insuspeito",
    nome: "Insuspeito",
    custoPontos: 1,
    efeito: "Cameras, revistas e triagens automaticas tratam voce como civil comum.",
    descricao:
      "Nada em voce chama atencao: nem cara de runner, nem implante a mostra, nem ficha. Cameras, revistas e triagens automaticas o tratam como civil comum.",
  },
];

export function buscarVantagem(id) {
  return vantagens.find((v) => v.id === id) ?? null;
}
