// Catalogo de habilidades especiais por arquetipo.
// Fonte: material/habilidades-3dt-cyberpunk.html (README.md dessa pasta).
// custoPontos: pontos de personagem gastos na criacao (barra de 9 pontos).
// custoPA: custo de ativacao em Pontos de Acao (PA = Habilidade x 5), null
// quando a habilidade e passiva/sem custo de ativacao.

export const ARQUETIPOS_HABILIDADE = Object.freeze({
  GERAL: "geral",
  VAMPIRO: "vampiro",
  HACKER: "hacker",
  ATLETA: "atleta",
  ANDROIDE: "androide",
});

export const habilidades = [
  // ===== Gerais — qualquer personagem =====
  {
    id: "ataque-especial",
    nome: "Ataque especial",
    arquetipo: ARQUETIPOS_HABILIDADE.GERAL,
    custoPontos: 1,
    custoPorNivel: true,
    custoPA: 2,
    efeito: "+2 na Forca de Ataque por nivel comprado, num golpe assinatura sempre igual.",
    descricao:
      "Um golpe assinatura. Ao usa-lo, some +2 na Forca de Ataque por nivel comprado. Custa 2 PA por uso e voce precisa descrever o golpe — sempre o mesmo.",
  },
  {
    id: "reflexos-rapidos",
    nome: "Reflexos rapidos",
    arquetipo: ARQUETIPOS_HABILIDADE.GERAL,
    custoPontos: 1,
    custoPA: null,
    efeito: "+2 na iniciativa; nunca e pego indefeso por nao ter agido ainda.",
    descricao:
      "+2 na iniciativa e voce nunca e pego indefeso por nao ter agido ainda. Contra emboscadas, tem direito a um teste de Habilidade para reagir mesmo assim.",
  },
  {
    id: "ataque-multiplo",
    nome: "Ataque multiplo",
    arquetipo: ARQUETIPOS_HABILIDADE.GERAL,
    custoPontos: 2,
    custoPA: null,
    efeito: "Divide a acao em golpes contra alvos diferentes, ate o valor de Habilidade.",
    descricao:
      "Divide sua acao em golpes contra alvos diferentes, ate o valor da sua Habilidade. O primeiro sai limpo, os seguintes com -1 cumulativo.",
  },
  {
    id: "contatos",
    nome: "Contatos",
    arquetipo: ARQUETIPOS_HABILIDADE.GERAL,
    custoPontos: 1,
    custoPA: null,
    efeito: "Uma vez por sessao, declara conhecer alguem util na situacao.",
    descricao:
      "Voce conhece gente. Uma vez por sessao, declare que conhece alguem util naquela situacao — o mestre define o preco do favor, mas a pessoa existe e atende.",
  },
  {
    id: "resistencia-a-dano",
    nome: "Resistencia a dano",
    arquetipo: ARQUETIPOS_HABILIDADE.GERAL,
    custoPontos: 2,
    custoPA: null,
    efeito: "+3 na Forca de Defesa contra um tipo de dano escolhido.",
    descricao:
      "Escolha um tipo de dano (fogo, eletrico, perfuracao, quimico). Contra ele, voce soma +3 na Forca de Defesa.",
  },

  // ===== Vampiro — cepa hemofagica =====
  {
    id: "regeneracao",
    nome: "Regeneracao",
    arquetipo: ARQUETIPOS_HABILIDADE.VAMPIRO,
    custoPontos: 2,
    custoPA: null,
    efeito: "Recupera 2 PV no inicio de cada turno (acima de 0 PV); nao funciona contra fogo.",
    descricao:
      "Recupera 2 PV no inicio de cada um dos seus turnos, desde que esteja acima de 0 PV. Nao funciona contra dano por fogo, que cicatriza como em qualquer humano.",
  },
  {
    id: "dreno",
    nome: "Dreno",
    arquetipo: ARQUETIPOS_HABILIDADE.VAMPIRO,
    custoPontos: 2,
    custoPA: null,
    efeito: "Ao acertar corpo a corpo, gasta a acao seguinte para causar 3 de dano e recuperar 3 PV.",
    descricao:
      "Se acertar um ataque corpo a corpo contra um alvo vivo, pode gastar sua acao seguinte para se alimentar: causa 3 de dano direto e recupera a mesma quantidade em PV. O alvo precisa estar imobilizado, caido ou indefeso.",
  },
  {
    id: "sentidos-noturnos",
    nome: "Sentidos noturnos",
    arquetipo: ARQUETIPOS_HABILIDADE.VAMPIRO,
    custoPontos: 1,
    custoPA: null,
    efeito: "Enxerga no escuro total e sente sangue fresco a 30 metros.",
    descricao:
      "Enxerga no escuro total e sente sangue fresco a ate 30 metros, atraves de paredes finas. Nenhuma penalidade por escuridao.",
  },
  {
    id: "presenca-hipnotica",
    nome: "Presenca hipnotica",
    arquetipo: ARQUETIPOS_HABILIDADE.VAMPIRO,
    custoPontos: 2,
    custoPA: 2,
    efeito: "Teste de Manipulacao contra a FD; se passar, o alvo perde a acao do turno.",
    descricao:
      "2 PA. Teste de Manipulacao contra a FD de um alvo que possa ver seus olhos. Se passar, ele perde a acao do turno, hesitando. Nao funciona duas vezes seguidas na mesma pessoa.",
  },
  {
    id: "velocidade-predatoria",
    nome: "Velocidade predatoria",
    arquetipo: ARQUETIPOS_HABILIDADE.VAMPIRO,
    custoPontos: 3,
    custoPA: 4,
    efeito: "Uma vez por combate, age duas vezes na mesma rodada; adianta a fome.",
    descricao:
      "Uma vez por combate, aja duas vezes na mesma rodada. Custa 4 PA e adianta a fome: no fim da cena, voce precisa se alimentar ou sofre -1 em todas as caracteristicas ate conseguir.",
  },

  // ===== Hacker — netrunner =====
  {
    id: "intrusao-remota",
    nome: "Intrusao remota",
    arquetipo: ARQUETIPOS_HABILIDADE.HACKER,
    custoPontos: 2,
    custoPA: 2,
    efeito: "Assume o controle de um sistema eletronico a vista ou na rede via teste de Maquinas.",
    descricao:
      "2 PA. Assume o controle de um sistema eletronico a vista ou na mesma rede: portas, cameras, elevadores, alarmes. Teste de Maquinas; a dificuldade sobe conforme a seguranca do alvo.",
  },
  {
    id: "travar-ciberware",
    nome: "Travar ciberware",
    arquetipo: ARQUETIPOS_HABILIDADE.HACKER,
    custoPontos: 2,
    custoPA: 2,
    efeito: "Teste de Maquinas contra a FD de um alvo com implantes; travando, -2 em Habilidade por um turno.",
    descricao:
      "2 PA. Teste de Maquinas contra a FD de um alvo com implantes. Se passar, o ciberware dele congela por um turno: -2 em Habilidade e nada de habilidades ciberneticas. Inutil contra quem e de carne pura.",
  },
  {
    id: "sequestro-de-drone",
    nome: "Sequestro de drone",
    arquetipo: ARQUETIPOS_HABILIDADE.HACKER,
    custoPontos: 2,
    custoPA: 3,
    efeito: "Rouba um drone inimigo por tres turnos.",
    descricao:
      "3 PA. Rouba um drone inimigo por tres turnos e o usa como se fosse seu. Depois disso ele queima e cai.",
  },
  {
    id: "visao-de-dados",
    nome: "Visao de dados",
    arquetipo: ARQUETIPOS_HABILIDADE.HACKER,
    custoPontos: 1,
    custoPA: null,
    efeito: "Enxerga a camada eletronica do ambiente: cameras, sensores, implantes.",
    descricao:
      "Enxerga a camada eletronica do ambiente: cameras, sensores, sinais, quem esta com implantes e quem nao esta. Voce sempre sabe onde estao os olhos da sala.",
  },
  {
    id: "porta-dos-fundos",
    nome: "Porta dos fundos",
    arquetipo: ARQUETIPOS_HABILIDADE.HACKER,
    custoPontos: 3,
    custoPA: null,
    efeito: "Uma vez por sessao, declara ja ter preparado um acesso num sistema encontrado.",
    descricao:
      "Uma vez por sessao, declare que ja deixou um acesso preparado num sistema que o grupo encontrar — e ele estava la desde antes. Voce escolhe o efeito: abrir uma rota, apagar registros, derrubar o alarme por uma cena.",
  },

  // ===== Atleta — corpo treinado, sem implante nenhum =====
  {
    id: "parkour-urbano",
    nome: "Parkour urbano",
    arquetipo: ARQUETIPOS_HABILIDADE.ATLETA,
    custoPontos: 1,
    custoPA: null,
    efeito: "Move-se pelo cenario sem testes; nunca sofre dano de queda abaixo de dois andares.",
    descricao:
      "Move-se pelo cenario sem testes: telhados, andaimes, escadas de incendio, vaos entre predios. Nunca sofre dano de queda abaixo de dois andares.",
  },
  {
    id: "esquiva-aprimorada",
    nome: "Esquiva aprimorada",
    arquetipo: ARQUETIPOS_HABILIDADE.ATLETA,
    custoPontos: 2,
    custoPA: null,
    efeito: "+2 no teste de Habilidade ao esquivar; mesmo falhando, soma Habilidade na FD.",
    descricao:
      "Ao esquivar, some +2 no teste de Habilidade. E, mesmo falhando, voce ainda soma Habilidade na Forca de Defesa em vez de comer o dano inteiro.",
  },
  {
    id: "folego-infinito",
    nome: "Folego infinito",
    arquetipo: ARQUETIPOS_HABILIDADE.ATLETA,
    custoPontos: 1,
    custoPA: null,
    efeito: "Ignora penalidades por exaustao, corrida prolongada, ar rarefeito ou gas leve.",
    descricao:
      "Ignora penalidades por exaustao, corrida prolongada, ar rarefeito ou gas em baixa concentracao. Em perseguicoes longas, voce vence por padrao contra quem nao tiver isso.",
  },
  {
    id: "golpe-preciso",
    nome: "Golpe preciso",
    arquetipo: ARQUETIPOS_HABILIDADE.ATLETA,
    custoPontos: 2,
    custoPA: 2,
    efeito: "Ataque que ignora ate 3 pontos de protecao do alvo observado por ao menos um turno.",
    descricao:
      "2 PA. Um ataque que ignora ate 3 pontos de protecao do alvo — junta, visor, articulacao de exoesqueleto. Exige que voce tenha observado o inimigo por ao menos um turno.",
  },
  {
    id: "segundo-folego",
    nome: "Segundo folego",
    arquetipo: ARQUETIPOS_HABILIDADE.ATLETA,
    custoPontos: 2,
    custoPA: null,
    efeito: "Uma vez por combate, abaixo de metade dos PV, recupera 5 PV e limpa penalidades temporarias.",
    descricao:
      "Uma vez por combate, ao chegar abaixo de metade dos PV, recupere 5 PV e limpe qualquer penalidade temporaria. Puro treino e teimosia.",
  },

  // ===== Meio androide — chassi sob a pele =====
  {
    id: "chassi-blindado",
    nome: "Chassi blindado",
    arquetipo: ARQUETIPOS_HABILIDADE.ANDROIDE,
    custoPontos: 2,
    custoPA: null,
    efeito: "+2 na Forca de Defesa, sempre ativo; nao soma com armadura vestida (vale a maior).",
    descricao:
      "+2 na Forca de Defesa, sempre ativo, sem custo. Nao some com armadura vestida: vale a maior das duas.",
  },
  {
    id: "membro-ferramenta",
    nome: "Membro-ferramenta",
    arquetipo: ARQUETIPOS_HABILIDADE.ANDROIDE,
    custoPontos: 1,
    custoPA: null,
    efeito: "Braco reconfiguravel; conta como equipamento sempre disponivel (+1 FA).",
    descricao:
      "Um braco se reconfigura: chave, macarico, gancho, arma branca. Conta como equipamento sempre disponivel (+1 FA) e resolve sozinho tarefas manuais que exigiriam ferramenta.",
  },
  {
    id: "coprocessador-tatico",
    nome: "Coprocessador tatico",
    arquetipo: ARQUETIPOS_HABILIDADE.ANDROIDE,
    custoPontos: 2,
    custoPA: 1,
    efeito: "Refaz um teste de Habilidade que acabou de falhar, uma vez por turno.",
    descricao: "1 PA. Refaz um teste de Habilidade que acabou de falhar. Utilizavel uma vez por turno.",
  },
  {
    id: "servo-forca",
    nome: "Servo-forca",
    arquetipo: ARQUETIPOS_HABILIDADE.ANDROIDE,
    custoPontos: 2,
    custoPA: null,
    efeito: "Forca conta como +2 para tarefas fisicas; +1 na FA de ataques corpo a corpo.",
    descricao:
      "Sua Forca conta como 2 pontos acima para carregar, arrombar, esmagar e segurar. Em dano, some +1 na FA de ataques corpo a corpo.",
  },
  {
    id: "interface-direta",
    nome: "Interface direta",
    arquetipo: ARQUETIPOS_HABILIDADE.ANDROIDE,
    custoPontos: 1,
    custoPA: null,
    efeito: "+2 em testes de Maquinas feitos com contato direto via cabo.",
    descricao:
      "Conecta-se fisicamente a qualquer sistema por um cabo no pulso. Concede +2 em testes de Maquinas feitos com contato direto — e faz de voce a melhor dupla possivel para a hacker.",
  },
];

export function habilidadesPorArquetipo(arquetipo) {
  return habilidades.filter((h) => h.arquetipo === arquetipo);
}

export function buscarHabilidade(id) {
  return habilidades.find((h) => h.id === id) ?? null;
}
