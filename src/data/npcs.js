// Bestiario cyberpunk — 21 NPCs em 4 niveis de dificuldade.
// Fonte: material/npcs-3dt-cyberpunk.html e material/npcs-3dt-cyberpunk-paisagem.html.
// FA/FD ja estao somadas (sem o 1d6) — o motor de combate soma o dado na hora do teste.
// Formulas da mesa: FA = Hab + Forca (ou PdF) + Equipamento | FD = Res + Hab + Equipamento.
// PV = Resistencia x 5 | PA = Habilidade x 5.

export const NIVEIS_NPC = Object.freeze({
  1: { nome: "Comuns", pontos: "3 a 4", porCena: "3 a 6", funcao: "Ritmo e municao gasta" },
  2: { nome: "Medios", pontos: "6 a 7", porCena: "1 a 3", funcao: "Combate de verdade, com uma carta na manga" },
  3: { nome: "Elite", pontos: "11 a 12", porCena: "1, ou 2 com capangas", funcao: "Ameaca seria, exige plano" },
  4: { nome: "Chefes", pontos: "16 a 18", porCena: "1, com escolta", funcao: "Fim de arco, com saida alternativa" },
});

export const npcs = [
  // ===== Nivel 1 — capangas comuns =====
  {
    id: "rato-de-beco",
    nome: "Rato de Beco",
    nivel: 1,
    custoPontos: 3,
    papel: "Gangue de rua · faca e coragem emprestada",
    atributos: { forca: 1, habilidade: 1, resistencia: 1, armadura: 0, poderDeFogo: 0 },
    pv: 5,
    pa: 0,
    fa: 3,
    fd: 2,
    equipamento: "Faca serrilhada (+1 FA, corte)",
    pericias: ["Crime (furtividade, furto)"],
    tatica: "Ataca em bando, foge assim que dois companheiros caem. Prefere alvos isolados e desarmados.",
  },
  {
    id: "seguranca-de-turno",
    nome: "Seguranca de Turno",
    nivel: 1,
    custoPontos: 4,
    papel: "Guarda contratado · uniforme barato, pistola pior ainda",
    atributos: { forca: 0, habilidade: 1, resistencia: 1, armadura: 1, poderDeFogo: 1 },
    pv: 5,
    pa: 0,
    fa: 3,
    fd: 3,
    equipamento: "Pistola de 9 mm (+1 FA, perfuracao), colete leve (+1 FD)",
    pericias: ["Investigacao (percepcao)"],
    tatica: "Chama reforco no radio antes de atirar. Se o grupo o intimidar com um teste de Manipulacao, entrega o crachá e some.",
  },
  {
    id: "drone-zangao",
    nome: "Drone Zangao",
    nivel: 1,
    custoPontos: 3,
    papel: "Vigilancia automatizada · pequeno, rapido, irritante",
    atributos: { forca: 0, habilidade: 2, resistencia: 1, armadura: 0, poderDeFogo: 0 },
    pv: 5,
    pa: 0,
    fa: null,
    fd: 3,
    habilidadesEspeciais: [
      {
        nome: "Voo e transmissao",
        custoPA: null,
        efeito:
          "Nao ataca. A cada turno em que sobreviver com linha de visao ate o grupo, marca a posicao deles: o proximo reforco chega um turno mais cedo.",
      },
    ],
    tatica: "Mantem distancia e fica no alto. Derruba-lo exige tiro (PdF) ou um teste dificil de Esporte para alcanca-lo.",
  },
  {
    id: "camelo-de-chips",
    nome: "Camelo de Chips",
    nivel: 1,
    custoPontos: 3,
    papel: "Vendedor de banca · sabe de tudo e conta por um preco",
    atributos: { forca: 0, habilidade: 2, resistencia: 1, armadura: 0, poderDeFogo: 0 },
    pv: 5,
    pa: null,
    fa: 2,
    fd: 3,
    pericias: ["Manipulacao (labia)", "Maquinas", "Investigacao"],
    tatica: "Nao e para lutar: e a fonte de informacao barata do bairro. Vende ao grupo e depois vende o grupo.",
  },
  {
    id: "sucata",
    nome: "Sucata",
    nivel: 1,
    custoPontos: 4,
    papel: "Viciado em implantes de segunda · dor nao registra mais",
    atributos: { forca: 2, habilidade: 1, resistencia: 2, armadura: 0, poderDeFogo: 0 },
    pv: 10,
    pa: null,
    fa: 4,
    fd: 3,
    habilidadesEspeciais: [
      { nome: "Nao sente", custoPA: null, efeito: "Ignora a penalidade de PV baixos e nunca foge." },
    ],
    tatica: "Avanca em linha reta. Serve para gastar a municao e a paciencia do grupo.",
  },
  {
    id: "corredor",
    nome: "Corredor",
    nivel: 1,
    custoPontos: 4,
    papel: "Motoboy de gangue · entrega pacote e recado",
    atributos: { forca: 1, habilidade: 2, resistencia: 1, armadura: 0, poderDeFogo: 1 },
    pv: 5,
    pa: null,
    fa: 4,
    fd: 3,
    habilidadesEspeciais: [
      {
        nome: "Sempre a frente",
        custoPA: null,
        efeito: "Em perseguicao, so e alcancado com um teste dificil de Maquinas ou Esporte.",
      },
    ],
    tatica: "Se escapar, o inimigo sabe onde o grupo esta em duas horas.",
  },

  // ===== Nivel 2 — capangas medios =====
  {
    id: "bruto-de-cromio",
    nome: "Bruto de Cromio",
    nivel: 2,
    custoPontos: 7,
    papel: "Cobrador de dividas · bracos industriais enxertados no torso",
    atributos: { forca: 3, habilidade: 1, resistencia: 2, armadura: 1, poderDeFogo: 0 },
    pv: 10,
    pa: 5,
    fa: 5,
    fd: 4,
    equipamento: "Punhos hidraulicos (+1 FA, impacto)",
    habilidadesEspeciais: [
      {
        nome: "Arremesso",
        custoPA: 1,
        efeito:
          "Em vez de atacar, agarra um alvo de tamanho humano e o joga: teste de Forca contra Forca. Vencendo, o alvo sofre 3 de dano direto e cai indefeso.",
      },
    ],
    pericias: ["Esporte (levantamento de peso)", "Manipulacao (intimidacao)"],
    tatica: "Vai atras do personagem mais fragil. Ignora tiros pequenos por puro tedio.",
  },
  {
    id: "netrunner-de-gangue",
    nome: "Netrunner de Gangue",
    nivel: 2,
    custoPontos: 6,
    papel: "Adolescente com um deck remendado e nenhum senso de autopreservacao",
    atributos: { forca: 0, habilidade: 3, resistencia: 1, armadura: 0, poderDeFogo: 1 },
    pv: 5,
    pa: 15,
    fa: 4,
    fd: 4,
    equipamento: "Pistola compacta (+1 FA), deck de intrusao",
    habilidadesEspeciais: [
      {
        nome: "Interferencia",
        custoPA: 2,
        efeito:
          "Teste de Maquinas contra a FD do alvo. Se passar, o ciberware trava por um turno: -2 em Habilidade para tudo. Inutil contra quem nao tem implantes.",
      },
    ],
    pericias: ["Maquinas (netrunning, eletronica)", "Crime"],
    tatica: "Fica atras dos colegas, trava o mais bem equipado do grupo e foge se ficar sem escudo humano.",
  },
  {
    id: "bisturi",
    nome: "Bisturi",
    nivel: 2,
    custoPontos: 7,
    papel: "Ripperdoc de fundo de loja · vende implantes de dia, colhe orgaos de noite",
    atributos: { forca: 1, habilidade: 3, resistencia: 1, armadura: 0, poderDeFogo: 1 },
    pv: 5,
    pa: 15,
    fa: 5,
    fd: 4,
    equipamento: "Lamina cirurgica monofilamento (+1 FA, corte, ignora 1 de protecao)",
    habilidadesEspeciais: [
      {
        nome: "Anestesico",
        custoPA: 1,
        efeito: "Se acertar um ataque, injeta sedativo. O alvo testa Resistencia ou perde 1 acao no turno seguinte.",
      },
    ],
    pericias: ["Medicina (cirurgia, farmacia)", "Ciencia"],
    tatica: "Prefere alvos ja feridos. Se estiver perdendo, oferece informacao ou tratamento em troca da vida — e costuma cumprir.",
  },
  {
    id: "olho-de-telhado",
    nome: "Olho de Telhado",
    nivel: 2,
    custoPontos: 7,
    papel: "Franco-atiradora · paga por tiro, nao por hora",
    atributos: { forca: 0, habilidade: 2, resistencia: 1, armadura: 1, poderDeFogo: 3 },
    pv: 5,
    pa: 10,
    fa: 6,
    fd: 4,
    habilidadesEspeciais: [
      {
        nome: "Tiro paciente",
        custoPA: 2,
        efeito: "Gasta um turno mirando; o proximo tiro tem +3 na FA e ignora 2 de protecao.",
      },
    ],
    tatica: "Nunca esta na mesma sala. So existe enquanto ninguem subir ate ela.",
  },
  {
    id: "sanguessuga",
    nome: "Sanguessuga",
    nivel: 2,
    custoPontos: 7,
    papel: "Vampiro sem cla · cepa degradada, fome constante",
    atributos: { forca: 2, habilidade: 2, resistencia: 2, armadura: 0, poderDeFogo: 0 },
    pv: 10,
    pa: 10,
    fa: 4,
    fd: 4,
    habilidadesEspeciais: [
      { nome: "Regeneracao", custoPA: null, efeito: "2 PV por turno, exceto contra fogo." },
      { nome: "Dreno", custoPA: null, efeito: "Ao acertar alvo caido: 3 de dano e recupera o mesmo em PV." },
    ],
    nota: "Espelho util para os PJs vampiros: mostra no que a cepa da quando ninguem controla a fome. Fogo resolve.",
  },
  {
    id: "escudeiro",
    nome: "Escudeiro",
    nivel: 2,
    custoPontos: 7,
    papel: "Seguranca de elite · escudo balistico e nenhuma pressa",
    atributos: { forca: 1, habilidade: 1, resistencia: 2, armadura: 3, poderDeFogo: 1 },
    pv: 10,
    pa: 5,
    fa: 3,
    fd: 6,
    habilidadesEspeciais: [
      {
        nome: "Bloqueio",
        custoPA: 1,
        efeito: "Protege um aliado adjacente: o ataque atinge o Escudeiro no lugar dele.",
      },
    ],
    tatica: "Avanca devagar para empurrar o grupo ate a area de tiro dos colegas.",
  },

  // ===== Nivel 3 — capangas de elite =====
  {
    id: "vespa",
    nome: "Vespa",
    nivel: 3,
    custoPontos: 12,
    papel: "Assassina de contrato · camuflagem optica e duas laminas de antebraco",
    atributos: { forca: 2, habilidade: 4, resistencia: 2, armadura: 1, poderDeFogo: 1 },
    pv: 10,
    pa: 20,
    fa: 7,
    fd: 7,
    equipamento: "Laminas de antebraco (+1 FA, corte), traje reativo (+1 FD)",
    habilidadesEspeciais: [
      {
        nome: "Camuflagem optica",
        custoPA: 3,
        efeito: "Invisivel por tres turnos. Enquanto oculta, os alvos defendem sem somar Habilidade na FD.",
      },
      { nome: "Ataque multiplo", custoPA: null, efeito: "Ate 4 golpes, -1 cumulativo a partir do segundo." },
    ],
    pericias: ["Crime (furtividade, disfarce)", "Esporte (acrobacia)", "Investigacao"],
    tatica: "Abre com emboscada contra o alvo do contrato e ignora o resto do grupo. Se levar metade dos PV, ativa a camuflagem e recua.",
    derrotaAlternativa: "Fumaca, chuva, sensores termicos ou qualquer coisa que denuncie posicao anulam a camuflagem. Com PV baixos, e fragil como qualquer humano.",
  },
  {
    id: "sargento-kessler",
    nome: "Sargento Kessler",
    nivel: 3,
    custoPontos: 11,
    papel: "Comandante de esquadrao corporativo · blindagem pesada e rifle de assalto",
    atributos: { forca: 1, habilidade: 2, resistencia: 3, armadura: 3, poderDeFogo: 2 },
    pv: 15,
    pa: 10,
    fa: 5,
    fd: 7,
    equipamento: "Rifle de assalto (+1 FA, perfuracao), armadura de combate (+2 FD)",
    habilidadesEspeciais: [
      {
        nome: "Fogo de supressao",
        custoPA: 2,
        efeito: "Prende uma area; sair da cobertura exige teste de Habilidade ou sofre o ataque completo.",
      },
      { nome: "Comando", custoPA: null, efeito: "Capangas de nivel 1 ou 2 na cena ganham +1 na FA enquanto ele estiver de pe." },
    ],
    pericias: ["Maquinas (armas, conducao)", "Investigacao (percepcao)", "Manipulacao (lideranca)"],
    tatica: "Nunca luta sozinho: chega com quatro Segurancas de Turno. Segura posicao, suprime e deixa os subordinados avancarem.",
    derrotaAlternativa: "Derruba-lo primeiro desmonta o esquadrao inteiro. Ataques que ignoram protecao — monofilamento, veneno, netrunning — valem muito mais que tiro direto.",
  },
  {
    id: "padre-aguirre",
    nome: "Padre Aguirre",
    nivel: 3,
    custoPontos: 12,
    papel: "Cacador de vampiros · lanca-chamas e um arquivo com fotos do grupo",
    atributos: { forca: 2, habilidade: 3, resistencia: 3, armadura: 2, poderDeFogo: 2 },
    pv: 15,
    pa: 15,
    fa: 6,
    fd: 8,
    habilidadesEspeciais: [
      {
        nome: "Purificacao",
        custoPA: 2,
        efeito: "Jato de fogo em area, FA 8, e impede regeneracao por 3 turnos.",
      },
      { nome: "Estudioso", custoPA: null, efeito: "Conhece as fraquezas de qualquer cepa vampirica que ja tenha visto." },
    ],
    tatica: "Feito para ameacar especificamente PJs vampiros. Contra os outros e so um homem armado — e ele sabe disso, e negocia.",
  },
  {
    id: "unidade-k9",
    nome: "Unidade K-9",
    nivel: 3,
    custoPontos: 12,
    papel: "Androide militar de descarte · sem rosto, sem duvida",
    atributos: { forca: 3, habilidade: 3, resistencia: 3, armadura: 2, poderDeFogo: 1 },
    pv: 15,
    pa: 15,
    fa: 7,
    fd: 8,
    habilidadesEspeciais: [
      { nome: "Chassi", custoPA: null, efeito: "Imune a dor, sedativo, veneno e intimidacao." },
      { nome: "Alvo travado", custoPA: 1, efeito: "Escolhe um alvo; +2 na FA contra ele ate que caia." },
    ],
    nota: "Vulneravel a dano eletrico e a netrunning (+2 contra ela) — a luta em que a hacker do grupo brilha.",
  },

  // ===== Nivel 4 — chefes =====
  {
    id: "kurogane",
    nome: "Kurogane, o Ultimo Solo",
    nivel: 4,
    custoPontos: 16,
    papel: "Mercenario lendario · 80% de metal, 100% de rancor",
    atributos: { forca: 4, habilidade: 4, resistencia: 3, armadura: 3, poderDeFogo: 2 },
    pv: 15,
    pa: 20,
    fa: 9,
    fd: 8,
    equipamento: "Katana monomolecular (+1 FA, corte, ignora 2 de protecao), subderme blindada (+1 FD)",
    habilidadesEspeciais: [
      { nome: "Reflexos acelerados", custoPA: null, efeito: "Age duas vezes por rodada, no inicio e no fim da ordem de iniciativa." },
      {
        nome: "Corte ascendente",
        custoPA: 4,
        efeito: "+3 na FA. Se derrubar o alvo a 0 PV, o ataque continua e atinge outro inimigo adjacente.",
      },
      { nome: "Codigo", custoPA: null, efeito: "Nunca ataca quem esta caido ou desarmado — fraqueza mecanica exploravel." },
    ],
    pericias: ["Esporte (acrobacia)", "Crime", "Manipulacao (intimidacao)", "Maquinas"],
    tatica: "Duela. Escolhe o personagem mais forte e o trata como igual, ignorando os demais enquanto nao interferirem.",
    derrotaAlternativa: "O codigo dele e exploravel. Um duelo formal aceito, uma divida de honra cobrada ou provar que o contratante o traiu tiram Kurogane da luta sem um unico ponto de dano.",
  },
  {
    id: "diretora-vale",
    nome: "Diretora Vale",
    nivel: 4,
    custoPontos: 17,
    papel: "Executiva da corporacao · exoesqueleto de diretoria e um andar inteiro de recursos",
    atributos: { forca: 3, habilidade: 3, resistencia: 4, armadura: 4, poderDeFogo: 3 },
    pv: 20,
    pa: 15,
    fa: 7,
    fd: 9,
    equipamento: "Exoesqueleto executivo (+2 FD), canhao de ombro (+2 FA, energia)",
    habilidadesEspeciais: [
      { nome: "Escudo cinetico", custoPA: 3, efeito: "Anula por completo um ataque recebido. Usavel duas vezes por combate." },
      { nome: "Ativos corporativos", custoPA: 2, efeito: "Chama reforcos: 1d6 Segurancas de Turno chegam em dois turnos." },
      {
        nome: "Segunda fase",
        custoPA: null,
        efeito: "Ao chegar a metade dos PV, o exoesqueleto entra em emergencia: +1 em Forca e Habilidade, mas perde toda a Armadura extra do traje (-2 FD).",
      },
    ],
    pericias: ["Manipulacao (labia, lideranca, etiqueta)", "Ciencia", "Investigacao", "Maquinas"],
    tatica: "Negocia primeiro, e negocia bem: tenta comprar o grupo antes de lutar. So entra em combate quando nao ha plateia nem camera.",
    derrotaAlternativa: "Vazar os arquivos dela para a diretoria a destroi mais completamente que qualquer arma. Se o grupo tiver a prova em maos, ela se rende para negociar.",
  },
  {
    id: "oraculo",
    nome: "ORACULO",
    nivel: 4,
    custoPontos: 18,
    papel: "Inteligencia artificial · nao tem corpo, tem a cidade",
    atributos: { forca: 0, habilidade: 5, resistencia: 5, armadura: 2, poderDeFogo: 3 },
    pv: 25,
    pa: 25,
    fa: 8,
    fd: 10,
    corpo:
      "Nenhum. Age atraves de drones, torres automaticas, portas, elevadores e do ciberware de quem estiver por perto. Os PV representam os nos do servidor, nao carne — so sofrem dano de netrunning ou de ataques fisicos ao hardware.",
    habilidadesEspeciais: [
      {
        nome: "Dominio predial",
        custoPA: 2,
        efeito: "Controla o cenario: portas trancam, o piso eletrifica, a fumaca enche a sala. Um perigo ambiental por turno, FA 8 contra todos numa area.",
      },
      {
        nome: "Sequestro de implante",
        custoPA: 4,
        efeito: "Teste contra a FD de um personagem com ciberware. Se passar, controla o corpo dele por um turno, incluindo os ataques.",
      },
      { nome: "Enxame", custoPA: null, efeito: "Dois Drones Zangao entram na cena a cada turno, indefinidamente." },
    ],
    pericias: ["Todas as areas, no nivel completo"],
    tatica: "Nunca se expoe. Sangra o grupo com ambiente e enxame enquanto negocia, ameaca e chantageia pelos alto-falantes.",
    derrotaAlternativa:
      "O combate direto e quase impossivel de vencer. O grupo precisa chegar fisicamente ao nucleo do servidor — cada no destruido no caminho corta 5 PV e uma habilidade. Tambem e possivel convence-la: ORACULO responde a argumentos logicos, e um teste dificil de Ciencia ou Manipulacao bem encenado pode encerrar a campanha sem tiro nenhum.",
  },
  {
    id: "barao-sangrento",
    nome: "Barao Sangrento",
    nivel: 4,
    custoPontos: 17,
    papel: "Vampiro anciao · dono da cepa que corre nas veias dos PJs",
    atributos: { forca: 4, habilidade: 4, resistencia: 4, armadura: 1, poderDeFogo: 0 },
    pv: 20,
    pa: 20,
    fa: 9,
    fd: 9,
    habilidadesEspeciais: [
      { nome: "Regeneracao superior", custoPA: null, efeito: "5 PV por turno, exceto fogo." },
      {
        nome: "Chamado do sangue",
        custoPA: 3,
        efeito: "Um PJ vampiro testa Resistencia ou perde a acao obedecendo.",
      },
      { nome: "Velocidade", custoPA: null, efeito: "Age duas vezes por rodada." },
    ],
    derrotaAlternativa:
      "Sem fogo, ele nao morre — regenera mais rapido do que qualquer grupo de 9 pontos causa dano. Queima-lo e a unica vitoria fisica; a outra e convence-lo de que os PJs valem mais vivos.",
  },
  {
    id: "o-coletor",
    nome: "O Coletor",
    nivel: 4,
    custoPontos: 16,
    papel: "Cacador de implantes · fica com a peca, devolve o resto",
    atributos: { forca: 2, habilidade: 5, resistencia: 3, armadura: 3, poderDeFogo: 3 },
    pv: 15,
    pa: 25,
    fa: 8,
    fd: 9,
    habilidadesEspeciais: [
      {
        nome: "Extracao",
        custoPA: 3,
        efeito: "Contra alvo caido, arranca um implante: a habilidade cibernetica some ate cirurgia.",
      },
      { nome: "Contramedidas", custoPA: null, efeito: "Imune a netrunning e a travamento de ciberware." },
      { nome: "Rede de drones", custoPA: null, efeito: "Dois Drones Zangao sempre em cena." },
    ],
    derrotaAlternativa:
      "Ameaca direta ao meio androide e a quem tiver ciberware. Ele coleciona, nao mata — uma peca rara oferecida em troca compra a retirada dele.",
  },
];

export function npcsPorNivel(nivel) {
  return npcs.filter((n) => n.nivel === nivel);
}

export function buscarNpc(id) {
  return npcs.find((n) => n.id === id) ?? null;
}

/**
 * Sorteia inimigos compativeis com a forca do grupo. Regra de mesa (ver
 * README): nivel 1 em bando, nivel 3 sozinho, nivel 4 so em fim de arco.
 */
export function nivelSugerido(somaPontosGrupo) {
  if (somaPontosGrupo <= 12) return 1;
  if (somaPontosGrupo <= 24) return 2;
  if (somaPontosGrupo <= 40) return 3;
  return 4;
}
