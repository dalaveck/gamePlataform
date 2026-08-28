// Desvantagens — devolvem pontos de personagem (custoPontos = pontos
// devolvidos). Regra da casa: teto de 3 pontos devolvidos por personagem
// (ver src/data/regras.js TETO_PONTOS_DESVANTAGENS e src/engine/personagem.js).
// Fonte: material/habilidades-3dt-cyberpunk.html.

export const desvantagens = [
  {
    id: "procurado",
    nome: "Procurado",
    custoPontos: 1,
    descricao:
      "Alguem com recursos quer voce — corporacao, gangue, policia. Uma vez por sessao o mestre pode fazer surgir alguem no seu encalco, no pior momento possivel.",
  },
  {
    id: "divida",
    nome: "Divida",
    custoPontos: 1,
    descricao:
      "Voce deve dinheiro ou um favor a gente que cobra com violencia. O credor aparece periodicamente, e o que ele pede raramente combina com o plano do grupo.",
  },
  {
    id: "codigo-de-honra",
    nome: "Codigo de honra",
    custoPontos: 1,
    descricao:
      "Voce tem uma linha que nao cruza: nao mata desarmado, nao trai contratante, nao deixa crianca para tras. Quebrar isso custa 5 PA e uma cena de crise.",
  },
  {
    id: "ponto-fraco",
    nome: "Ponto fraco",
    custoPontos: 1,
    descricao:
      "Um tipo especifico de dano derruba voce. Escolha um: fogo, eletrico, quimico, sonico. Contra ele, sua Forca de Defesa nao soma Resistencia.",
  },
  {
    id: "furia",
    nome: "Furia",
    custoPontos: 1,
    descricao:
      "Um gatilho definido por voce. Ao ve-lo, teste Habilidade: falhando, ataca o responsavel e nao pode recuar, negociar ou fugir enquanto ele estiver de pe.",
  },
  {
    id: "corpo-fragil",
    nome: "Corpo fragil",
    custoPontos: 2,
    descricao:
      "Seus PV sao calculados como Resistencia x 3 em vez de x 5. Serve para quem quer investir tudo em Habilidade e aceitar que morre rapido.",
  },
  {
    id: "dependencia",
    nome: "Dependencia",
    custoPontos: 1,
    descricao:
      "Remedio, estimulante, supressor de rejeicao, sangue. Sem a dose diaria, -1 em todas as caracteristicas por dia de abstinencia, cumulativo ate voce conseguir.",
  },
  {
    id: "marca-registrada",
    nome: "Marca registrada",
    custoPontos: 1,
    descricao:
      "Algo em voce e inconfundivel: presas, um braco de cromio, uma cicatriz, olhos errados. Impossivel passar despercebido ou negar que estava na cena.",
  },
  {
    id: "protegido",
    nome: "Protegido",
    custoPontos: 1,
    descricao:
      "Alguem depende de voce: irma, filho, mentor doente. Nao sabe se defender e e o primeiro alvo de qualquer inimigo que descubra a ligacao.",
  },
  {
    id: "sem-registro",
    nome: "Sem registro",
    custoPontos: 1,
    descricao:
      "Voce nao existe em base de dados nenhuma. Nada de hospital publico, transporte oficial, emprego legal ou qualquer porta que exija identificacao.",
  },
];

// Desvantagens obrigatorias por arquetipo (nao contam para o teto de 3
// pontos porque sao parte do conceito, nao escolha livre — ver
// habilidades-3dt-cyberpunk.html, avisos dos grupos vampiro/androide).
export const desvantagensObrigatorias = {
  vampiro: {
    id: "fome",
    nome: "Fome",
    custoPontos: 1,
    descricao:
      "Se passar uma sessao inteira sem se alimentar, perde 1 PV por cena e -1 em Habilidade. Sol direto causa 2 de dano por turno, ignorando Armadura.",
  },
  androide: {
    id: "hardware",
    nome: "Hardware",
    custoPontos: 1,
    descricao:
      "Dano eletrico e ataques de netrunning contra voce recebem +2. Alem disso, voce e alvo valido para tudo que afeta ciberware, incluindo habilidades de colegas de grupo que errarem o alvo.",
  },
};

export function buscarDesvantagem(id) {
  return desvantagens.find((d) => d.id === id) ?? null;
}
