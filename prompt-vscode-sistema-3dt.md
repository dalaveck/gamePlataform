# Prompt para VS Code (Claude Code / Copilot) — Sistema de RPG 3D&T com Mestre Semi-Automático

> Instruções de uso: cole este conteúdo como prompt inicial no VS Code (extensão Claude Code ou
> equivalente), dentro da pasta do projeto. Coloque também `IAcontext.md`, `ROADMAP.md` e o PDF
> do manual (`3dt-alpha-manual-revisado-biblioteca-elfica.pdf`) na raiz do projeto antes de começar.
> Se este projeto reaproveitar o código do gerador de fichas anterior, cole aquele código também
> na pasta (ou referencie o repositório) para o assistente reconhecer o que já existe.

---

## LEIA PRIMEIRO

Antes de escrever qualquer código, leia `IAcontext.md` e `ROADMAP.md` na raiz do projeto — eles
contêm decisões de arquitetura já tomadas, o histórico do projeto e o plano de fases. Siga a ordem
de fases descrita no `ROADMAP.md`; não pule etapas nem implemente tudo de uma vez em um único
commit gigante. Ao final de cada fase, **atualize o `ROADMAP.md`** marcando os itens concluídos, e
se alguma decisão nova de arquitetura for tomada, **registre em `IAcontext.md`**.

---

## OBJETIVO DO PROJETO

Construir um sistema de RPG completo, jogável por qualquer pessoa via navegador (sem instalação),
baseado nas regras do **3D&T Alpha**, com um **Mestre/Narrador semi-automático**: o sistema narra
a aventura sozinho, usando tabelas de eventos com pesos de probabilidade (algumas coisas têm mais
chance de acontecer que outras) e resolve toda a mecânica do jogo (testes, combate, PV/PM)
automaticamente. Jogadores entram em uma sala/sessão com seus personagens (reaproveitando o
gerador de fichas já existente) e jogam em tempo real, cada um no próprio dispositivo.

---

## DECISÕES TÉCNICAS (já definidas — não reabrir esta discussão sem justificativa forte)

- **Frontend**: React + JSX + Vite. Não usar Flutter (decisão consciente, ver `IAcontext.md`).
- **Estilização**: CSS puro ou Tailwind — escolha uma abordagem e mantenha consistente em todo o
  projeto (evite misturar).
- **Backend / tempo real**: Firebase (Firestore para dados de sessão + Auth anônima para
  identificar jogadores sem exigir cadastro). Escolhido por não exigir servidor próprio.
- **Hospedagem**: Vercel ou Netlify para o frontend + Firebase para o backend.
- **Dados**: 1d6, seguindo o padrão do manual.

---

## ARQUITETURA GERAL

```
/src
  /data              -> raças, vantagens, desvantagens, perícias (extraídas do manual em PDF)
    /mapa
      regioes.js     -> as 41 regiões do mundo cyberpunk
      localidades.js -> localidades de cada região (mín. 4 por região)
  /engine            -> lógica pura de regras, sem UI (testável isoladamente)
    dice.js
    combate.js
    testes.js
    personagem.js
    /narrator
      tabelas.js
      sorteio.js
      templates.js
      motor.js
      mapa.js        -> funções de seleção de região/localidade para alimentar a narração
  /components
    /ficha           -> componentes do gerador de ficha (Fase 0, já existente)
    /sessao          -> componentes de sala/mesa de jogo
    /combate         -> UI de combate
  /services
    firebase.js      -> inicialização e helpers do Firestore/Auth
    sessaoService.js -> criar/entrar/sincronizar sessão
  /hooks
    useSessao.js
    usePersonagem.js
  App.jsx
```

Mantenha o **motor de regras (`/engine`) totalmente desacoplado da UI** — ele deve ser testável
chamando funções puras, sem depender de componentes React. Isso é importante porque o motor do
Mestre semi-automático vai crescer bastante e precisa ser confiável.

---

## ESPECIFICAÇÃO: MOTOR DO MESTRE SEMI-AUTOMÁTICO

Este é o coração do projeto. Funciona em cima de **tabelas de eventos ponderadas** — ou seja,
listas de possíveis acontecimentos, cada um com um peso relativo que define a chance de ser
sorteado.

### 1. Categorias de evento
Defina pelo menos estas categorias de tabela (podem ser expandidas depois):
- `exploracao` — descrições de ambiente, pistas, itens encontrados.
- `combate` — encontros com inimigos (defina inimigos simples usando as mesmas características
  do 3D&T: F, H, R, A, PdF).
- `social` — NPCs, diálogos, escolhas morais.
- `armadilha` — testes de característica/perícia sob risco.
- `tesouro` — recompensas, itens.
- `reviravolta` — eventos de história maiores, plot twists.

### 2. Sistema de pesos (raridade)
Cada entrada de uma tabela tem uma raridade, e cada raridade tem um peso relativo (ajustável):
- `comum` → peso 60
- `incomum` → peso 25
- `raro` → peso 10
- `epico` → peso 5

Implemente uma função de sorteio ponderado genérica, por exemplo:

```js
// engine/narrator/sorteio.js
export function sortearPonderado(itens) {
  // itens: [{ id, peso, ...dados }]
  const total = itens.reduce((soma, item) => soma + item.peso, 0);
  let alvo = Math.random() * total;
  for (const item of itens) {
    if (alvo < item.peso) return item;
    alvo -= item.peso;
  }
  return itens[itens.length - 1];
}
```

### 3. Templates narrativos
Cada entrada de tabela referencia um ou mais templates de texto com variáveis, por exemplo:

```js
{
  id: "encontro_goblins",
  categoria: "combate",
  raridade: "comum",
  peso: 60,
  template: "Ao virar a esquina de {local}, {personagem} avista {quantidade} goblins famintos.",
  efeito: { tipo: "iniciarCombate", inimigos: ["goblin", "goblin"] }
}
```

O motor deve:
1. Receber o contexto atual (local, personagens presentes, eventos já ocorridos na sessão — para
   evitar repetição imediata).
2. Sortear uma categoria (ou receber a categoria já decidida pelo fluxo do jogo) e, dentro dela,
   sortear uma entrada usando `sortearPonderado`.
3. Preencher o template com os dados do contexto.
4. Retornar um objeto `{ texto, efeitoMecanico }` — o texto vai para o log narrativo da sessão, e o
   efeito mecânico é processado pelo motor de regras (ex.: iniciar combate, aplicar dano, conceder
   item).

### 4. Ajuste de "tom" da campanha
Permita configurar, por sessão, um multiplicador de peso por categoria (ex.: campanha "mais
combate" aumenta o peso de `combate`, campanha "mais social" aumenta o peso de `social`). Guarde
essa configuração no documento da sessão no Firestore.

### 5. Evitar repetição
Mantenha um histórico curto (últimos N eventos) na sessão e penalize (reduza peso temporariamente)
de entradas já usadas recentemente, para a narrativa não repetir a mesma cena.

---

## ESPECIFICAÇÃO: MAPA DO MUNDO (41 REGIÕES CYBERPUNK)

O cenário padrão do sistema é uma ambientação **cyberpunk**. O mundo é dividido em um **mapa fixo
de 41 regiões**, cada uma baseada em um conceito clássico do universo cyberpunk (megacorporações,
submundo, favelas verticais, hackers, biotecnologia, IA, etc.). **Cada região deve ter no mínimo 4
localidades visitáveis.** Essas localidades são a matéria-prima usada pelo motor do Mestre
semi-automático para gerar descrições de cena, ambientação e ganchos narrativos — ou seja, este
mapa alimenta diretamente os `templates` da seção "Motor do Mestre Semi-Automático" acima.

### 1. Lista das 41 regiões (nomes e temas — use exatamente esta lista como base)

1. **Distrito de Neon** — comércio exagerado, publicidade holográfica, vida noturna.
2. **Torres Corporativas** — sedes de megacorporações, andares de vidro e segurança pesada.
3. **Favelas Verticais** — construções empilhadas caoticamente, pobreza e improviso.
4. **Submundo dos Esgotos** — túneis, dutos e vias abandonadas sob a cidade.
5. **Zona Franca dos Hackers** — reduto físico de hackers e ativistas digitais.
6. **Mercado Negro de Implantes** — comércio ilegal de próteses e cibernética.
7. **Distrito Vermelho** — entretenimento adulto, clubes, néon e vícios.
8. **Portos Automatizados** — carga movida por drones e IA logística.
9. **Estaleiros Abandonados** — indústria naval decadente, esconderijos.
10. **Arcologia Central** — uma cidade inteira dentro de um único megaprédio.
11. **Zona Industrial Tóxica** — fábricas poluentes, ar irrespirável.
12. **Clínicas de Aumento Cibernético** — cirurgias de implantes, legais e clandestinas.
13. **Colônia de Clones** — produção biotecnológica de corpos e mão de obra.
14. **Templo da IA** — culto religioso dedicado a uma inteligência artificial.
15. **Arena de Combate Clandestina** — lutas ilegais, apostas, submundo do crime.
16. **Bairro dos Refugiados Climáticos** — deslocados por desastres ambientais.
17. **Estação Maglev Central** — hub de transporte de alta velocidade da cidade.
18. **Elevador Orbital** — ligação entre a superfície e estações espaciais.
19. **Plataformas Flutuantes** — estruturas offshore, independentes das leis terrestres.
20. **Zona de Exclusão Radioativa** — área contaminada, perigosa e inexplorada.
21. **Complexo de Vigilância Estatal** — centro de controle e monitoramento em massa.
22. **Distrito da Mídia** — estúdios, torres de transmissão, propaganda constante.
23. **Cassino Quântico** — jogos de azar com tecnologia de probabilidade manipulada.
24. **Mercado Noturno** — comércio informal, comida de rua, contrabando leve.
25. **Necrópole Digital** — mercado de memórias e upload de mentes.
26. **Guilda dos Mercenários** — quartel-general de caçadores de recompensa e soldados de aluguel.
27. **Laboratório de Biotecnologia** — pesquisa genética, experimentos questionáveis.
28. **Zona Autônoma dos Sindicatos do Crime** — território controlado por facções criminosas.
29. **Bairro Labiríntico (Nova Kowloon)** — densidade extrema, vielas verticais infinitas.
30. **Subestação de Energia de Fusão** — infraestrutura crítica de energia da cidade.
31. **Lounges de Conexão Neural** — espaços físicos para "jack-in" em redes virtuais.
32. **Cemitério de Drones** — sucata tecnológica, robôs abandonados, catadores.
33. **Zoológico Genético** — criaturas modificadas geneticamente em exibição.
34. **Distrito Religioso Sincrético** — mistura de cultos antigos e tecnológicos.
35. **Academia de Treinamento Corporativo** — formação de agentes e executivos.
36. **Zona de Testes Militares** — armamentos experimentais, área restrita.
37. **Bairro dos Artistas Underground** — arte de rua, música, resistência cultural.
38. **Terminal de Contrabando** — ponto de entrada de mercadorias ilegais.
39. **Jardim Hidropônico** — um dos últimos redutos de natureza cultivada da cidade.
40. **Prisão Privatizada** — presídio administrado por corporação, trabalho forçado.
41. **Ruínas da Cidade Antiga** — vestígios do mundo pré-colapso, anterior à era cyberpunk.

### 2. Estrutura de dados

```js
// data/mapa/regioes.js
export const regioes = [
  {
    id: "distrito-neon",
    nome: "Distrito de Neon",
    tema: "Comércio exagerado, publicidade holográfica, vida noturna",
    descricaoBase: "Ruas encharcadas refletem letreiros holográficos que nunca se apagam...",
    tagsNarrativas: ["comercial", "noturno", "aglomerado"], // usadas para casar com tabelas do motor
  },
  // ...41 regiões no total, seguindo a lista acima
];
```

```js
// data/mapa/localidades.js
export const localidades = [
  {
    id: "distrito-neon-mercado-replicas",
    regiaoId: "distrito-neon",
    nome: "Mercado das Réplicas",
    tipo: "comercial", // comercial | perigo | social | marco | secreto
    descricaoBase: "Bancas vendem cópias piratas de tudo: roupas de grife, implantes, memórias.",
    ganchosNarrativos: [
      "Um vendedor oferece um implante 'quase original' por um preço bom demais.",
      "Alguém reconhece um item roubado do grupo sendo vendido ali.",
    ],
  },
  // mínimo 4 localidades por região (id da região em regiaoId)
];
```

### 3. Exemplos completos (use como padrão para gerar as outras 38 regiões)

Gere as localidades das demais regiões seguindo exatamente este padrão (nome, tipo, descrição
curta, 1–3 ganchos narrativos). Cada região precisa de no mínimo 4 localidades, cobrindo tipos
variados (não deixe todas do tipo `comercial`, por exemplo — misture `perigo`, `social`, `marco`,
`secreto` para dar variedade ao motor de narração).

**Distrito de Neon** (`distrito-neon`):
1. Mercado das Réplicas (comercial)
2. Beco das Apostas (perigo)
3. Terraço dos Executivos (social)
4. Torre do Relógio Holográfico (marco)

**Favelas Verticais** (`favelas-verticais`):
1. Escadaria dos Mil Degraus (marco)
2. Oficina do Sucateiro Chen (comercial)
3. Pátio Comunitário (social)
4. Fiação Exposta (perigo)

**Zona Franca dos Hackers** (`zona-franca-hackers`):
1. Café Criptografado (social)
2. Servidor Fantasma (secreto)
3. Feira de Hardware Pirata (comercial)
4. Beco dos Firewalls Quebrados (perigo)

### 4. Como o motor do Mestre usa o mapa

- Cada sessão começa associada a uma região inicial (aleatória ou escolhida pelos jogadores).
- Ao gerar um evento (ver `sortearPonderado`), o motor deve preferir localidades da região atual
  para preencher a variável `{local}` dos templates narrativos.
- Deslocar o grupo para outra região deve ser uma ação possível dentro do jogo (ex.: "viajar para
  [região]"), atualizando o contexto da sessão.
- O `tipo` da localidade (comercial, perigo, social, marco, secreto) pode influenciar qual
  categoria de tabela do motor (`combate`, `social`, `armadilha`, `tesouro`, `reviravolta`) tem
  mais chance de ser sorteada naquele momento — por exemplo, localidades do tipo `perigo` devem
  aumentar temporariamente o peso da categoria `combate`/`armadilha`.
- Guarde no `IAcontext.md` a lista final das 41 regiões implementadas, para consulta futura.

---

## ESPECIFICAÇÃO: SESSÃO / SALA MULTIPLAYER

- Um jogador cria uma sala e recebe um código curto (ex.: 6 caracteres).
- Outros jogadores entram digitando o código.
- Cada jogador vincula uma ficha de personagem (criada no gerador de fichas, Fase 0) à sessão.
- O estado da sessão (log narrativo, turno atual, personagens presentes, PV/PM atuais) fica no
  Firestore e é sincronizado em tempo real para todos os participantes via listeners.
- Não é necessário um "mestre humano" logado — o motor semi-automático assume esse papel, mas
  deixe a arquitetura aberta para, no futuro (Fase 7 do roadmap), um mestre humano poder intervir
  ou revisar o que o motor sugeriu.

---

## ESPECIFICAÇÃO: RESOLUÇÃO DE COMBATE

Reaproveite as fórmulas confirmadas do manual (documentadas em `IAcontext.md`):
- Força de Ataque (corpo a corpo) = Força + Habilidade + 1d
- Força de Ataque (à distância) = Poder de Fogo + Habilidade + 1d
- Força de Defesa = Armadura + Habilidade + 1d
- PV = PM = 5 × Resistência (Resistência 0 → 1 PV/PM)

Fluxo de turno automatizado:
1. Determinar iniciativa (Habilidade + 1d, do maior para o menor).
2. Para cada personagem/inimigo no turno, o jogador (ou o motor, para inimigos) escolhe uma ação
   simples: Atacar, Defender, Usar Perícia/Vantagem, Fugir.
3. O motor de regras calcula o resultado (FA vs FD) e aplica dano/efeitos automaticamente.
4. Verifica condições especiais (0 PV → nocaute/morte conforme regra do manual; "Perto da Morte"
   quando PV ≤ Resistência).
5. Gera uma linha narrativa curta descrevendo o resultado (reaproveitando o sistema de templates
   do motor do Mestre).

---

## FLUXO DE JOGO (visão do usuário final)

1. Jogador acessa o site.
2. Cria um personagem (fluxo já existente do gerador de fichas) ou carrega um salvo.
3. Cria uma sala nova ou entra em uma existente com um código.
4. Ao iniciar a sessão, o Mestre semi-automático narra a cena inicial.
5. Jogadores tomam ações (texto livre curto ou botões de ação predefinidos); o motor decide o
   próximo evento, pondera probabilidades e narra a consequência.
6. Combates são resolvidos automaticamente com base nas ações escolhidas.
7. A sessão continua até os jogadores decidirem encerrar; o progresso pode ser salvo (Fase 6 do
   roadmap) para continuar depois.

---

## O QUE FAZER AGORA (primeira entrega)

Siga a Fase 1 do `ROADMAP.md` primeiro: implemente **apenas o motor de regras puro**
(`/src/engine`), com testes simples, sem UI de sessão ainda. Isso garante uma base sólida antes de
partir para multiplayer e narrativa automática. Só avance para a Fase 2 em diante depois que a
Fase 1 estiver funcional e validada.

Ao final de cada fase entregue:
- Código funcional e comentado.
- Atualização do `ROADMAP.md` (itens marcados como concluídos).
- Se necessário, atualização do `IAcontext.md` com novas decisões tomadas.
