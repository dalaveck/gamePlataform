// As 41 regioes do mapa fixo do mundo cyberpunk.
// Lista fechada — nao alterar sem atualizar IAcontext.md e ROADMAP.md
// (ver prompt-vscode-sistema-3dt.md, secao "Mapa do Mundo").

export const regioes = [
  { id: "distrito-neon", nome: "Distrito de Neon", tema: "Comercio exagerado, publicidade holografica, vida noturna" },
  { id: "torres-corporativas", nome: "Torres Corporativas", tema: "Sedes de megacorporacoes, andares de vidro e seguranca pesada" },
  { id: "favelas-verticais", nome: "Favelas Verticais", tema: "Construcoes empilhadas caoticamente, pobreza e improviso" },
  { id: "submundo-dos-esgotos", nome: "Submundo dos Esgotos", tema: "Tuneis, dutos e vias abandonadas sob a cidade" },
  { id: "zona-franca-hackers", nome: "Zona Franca dos Hackers", tema: "Reduto fisico de hackers e ativistas digitais" },
  { id: "mercado-negro-implantes", nome: "Mercado Negro de Implantes", tema: "Comercio ilegal de proteses e cibernetica" },
  { id: "distrito-vermelho", nome: "Distrito Vermelho", tema: "Entretenimento adulto, clubes, neon e vicios" },
  { id: "portos-automatizados", nome: "Portos Automatizados", tema: "Carga movida por drones e IA logistica" },
  { id: "estaleiros-abandonados", nome: "Estaleiros Abandonados", tema: "Industria naval decadente, esconderijos" },
  { id: "arcologia-central", nome: "Arcologia Central", tema: "Uma cidade inteira dentro de um unico megapredio" },
  { id: "zona-industrial-toxica", nome: "Zona Industrial Toxica", tema: "Fabricas poluentes, ar irrespiravel" },
  { id: "clinicas-aumento-cibernetico", nome: "Clinicas de Aumento Cibernetico", tema: "Cirurgias de implantes, legais e clandestinas" },
  { id: "colonia-de-clones", nome: "Colonia de Clones", tema: "Producao biotecnologica de corpos e mao de obra" },
  { id: "templo-da-ia", nome: "Templo da IA", tema: "Culto religioso dedicado a uma inteligencia artificial" },
  { id: "arena-de-combate-clandestina", nome: "Arena de Combate Clandestina", tema: "Lutas ilegais, apostas, submundo do crime" },
  { id: "bairro-refugiados-climaticos", nome: "Bairro dos Refugiados Climaticos", tema: "Deslocados por desastres ambientais" },
  { id: "estacao-maglev-central", nome: "Estacao Maglev Central", tema: "Hub de transporte de alta velocidade da cidade" },
  { id: "elevador-orbital", nome: "Elevador Orbital", tema: "Ligacao entre a superficie e estacoes espaciais" },
  { id: "plataformas-flutuantes", nome: "Plataformas Flutuantes", tema: "Estruturas offshore, independentes das leis terrestres" },
  { id: "zona-exclusao-radioativa", nome: "Zona de Exclusao Radioativa", tema: "Area contaminada, perigosa e inexplorada" },
  { id: "complexo-vigilancia-estatal", nome: "Complexo de Vigilancia Estatal", tema: "Centro de controle e monitoramento em massa" },
  { id: "distrito-da-midia", nome: "Distrito da Midia", tema: "Estudios, torres de transmissao, propaganda constante" },
  { id: "cassino-quantico", nome: "Cassino Quantico", tema: "Jogos de azar com tecnologia de probabilidade manipulada" },
  { id: "mercado-noturno", nome: "Mercado Noturno", tema: "Comercio informal, comida de rua, contrabando leve" },
  { id: "necropole-digital", nome: "Necropole Digital", tema: "Mercado de memorias e upload de mentes" },
  { id: "guilda-dos-mercenarios", nome: "Guilda dos Mercenarios", tema: "Quartel-general de cacadores de recompensa e soldados de aluguel" },
  { id: "laboratorio-de-biotecnologia", nome: "Laboratorio de Biotecnologia", tema: "Pesquisa genetica, experimentos questionaveis" },
  { id: "zona-autonoma-sindicatos-crime", nome: "Zona Autonoma dos Sindicatos do Crime", tema: "Territorio controlado por faccoes criminosas" },
  { id: "bairro-labirintico-nova-kowloon", nome: "Bairro Labirintico (Nova Kowloon)", tema: "Densidade extrema, vielas verticais infinitas" },
  { id: "subestacao-energia-fusao", nome: "Subestacao de Energia de Fusao", tema: "Infraestrutura critica de energia da cidade" },
  { id: "lounges-conexao-neural", nome: "Lounges de Conexao Neural", tema: "Espacos fisicos para \"jack-in\" em redes virtuais" },
  { id: "cemiterio-de-drones", nome: "Cemiterio de Drones", tema: "Sucata tecnologica, robos abandonados, catadores" },
  { id: "zoologico-genetico", nome: "Zoologico Genetico", tema: "Criaturas modificadas geneticamente em exibicao" },
  { id: "distrito-religioso-sincretico", nome: "Distrito Religioso Sincretico", tema: "Mistura de cultos antigos e tecnologicos" },
  { id: "academia-treinamento-corporativo", nome: "Academia de Treinamento Corporativo", tema: "Formacao de agentes e executivos" },
  { id: "zona-de-testes-militares", nome: "Zona de Testes Militares", tema: "Armamentos experimentais, area restrita" },
  { id: "bairro-artistas-underground", nome: "Bairro dos Artistas Underground", tema: "Arte de rua, musica, resistencia cultural" },
  { id: "terminal-de-contrabando", nome: "Terminal de Contrabando", tema: "Ponto de entrada de mercadorias ilegais" },
  { id: "jardim-hidroponico", nome: "Jardim Hidroponico", tema: "Um dos ultimos redutos de natureza cultivada da cidade" },
  { id: "prisao-privatizada", nome: "Prisao Privatizada", tema: "Presidio administrado por corporacao, trabalho forcado" },
  { id: "ruinas-cidade-antiga", nome: "Ruinas da Cidade Antiga", tema: "Vestigios do mundo pre-colapso, anterior a era cyberpunk" },
];

export function buscarRegiao(id) {
  return regioes.find((r) => r.id === id) ?? null;
}
