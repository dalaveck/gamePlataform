# ROADMAP.md — Plano de Fases do Sistema de RPG 3D&T

> Ordem sugerida de implementação. Cada fase deve ser funcional e testável isoladamente antes de
> avançar para a próxima. Marque o status conforme o progresso (⬜ não iniciado / 🟨 em andamento / ✅ concluído).

---

## Fase 0 — Gerador de Fichas ✅
- Ficha de personagem completa (características, raça, vantagens, perícias, desvantagens).
- Cálculo automático de pontos.
- Exportação/compartilhamento.

---

## Fase 0.5 — Material de mesa (fichas e referências HTML) 🟨

Objetivo: consolidar o material impresso/HTML já produzido para a campanha cyberpunk e transformá-lo
na **fonte de verdade dos dados** que as fases seguintes vão consumir. Todos os arquivos estão em
`/material/` (ver `material/README.md`).

### 0.5.1 — Fichas de personagem ✅
- [x] `ficha-3dt-cyberpunk.html` — versão retrato A4, preenchível no navegador.
- [x] `ficha-3dt-cyberpunk-paisagem.html` — versão paisagem A4, cabe em uma folha só.
- [x] Campos: características (valor + buff), PV, PA, iniciativa, tipos de ataque, defesa,
      habilidades, perícias por área, vantagens, desvantagens, dinheiro, equipamento, anotações.
- [x] Salvar/carregar em `.json` e exportar em PDF pelo próprio navegador.

### 0.5.2 — Material de apoio ✅
- [x] `regras-3dt-resumo.html` + versão paisagem — resumo de regras da mesa.
- [x] `habilidades-3dt-cyberpunk.html` + versão paisagem — catálogo de habilidades especiais por
      arquétipo (vampiro, hacker, atleta, meio andróide, gerais), vantagens e desvantagens.
- [x] `npcs-3dt-cyberpunk.html` + versão paisagem — bestiário com 20 NPCs em 4 níveis de dificuldade.
- [x] `painel-mestre-3dt.html` — painel do mestre com rastreador de iniciativa, elenco, história e
      diário de sessão; salva a campanha em `.json`.

### 0.5.3 — Migração para dados do sistema 🟨
Objetivo: o conteúdo hoje escrito à mão no HTML vira dado estruturado consumido pelo app.
- [x] `data/habilidades.js` — catálogo de habilidades especiais (id, nome, arquétipo, custo em
      pontos, custo em PA, efeito, restrições). Fonte: `material/habilidades-3dt-cyberpunk.html`.
- [x] `data/vantagens.js` e `data/desvantagens.js` — incluindo o teto de 3 pontos em desvantagens
      (desvantagens obrigatórias de arquétipo — Fome/Hardware — ficam à parte, em
      `desvantagensObrigatorias`, e não contam para o teto).
- [x] `data/npcs.js` — 21 NPCs do bestiário como fichas completas (F, H, R, A, PdF, PV, PA, FA,
      FD, habilidades, tática, condição de derrota alternativa) e campo `nivel` de 1 a 4, com
      `nivelSugerido()` para o motor do Mestre sortear inimigos compatíveis com a força do grupo.
- [x] `data/arquetipos.js` — vampiro, hacker, atleta, meio andróide: habilidades disponíveis e
      desvantagem obrigatória de cada um.
- [x] `data/mapa/regioes.js` — as 41 regiões (nome + tema), transcritas do prompt original.
- [x] `data/pericias.js` — as 11 áreas fixas (`AREAS_PERICIA`), usadas pela ficha (Fase 1.5).
- [ ] `data/mapa/localidades.js` — só as 3 regiões de exemplo do prompt original estão preenchidas
      (12 localidades). Faltam as localidades das outras 38 regiões — ver comentário no topo do
      arquivo. Fica para a Fase 3 (motor do Mestre), que é quem consome esse dado.
- [ ] Importador de compatibilidade: o `.json` posicional salvo pelas fichas HTML antigas
      (`material/ficha-3dt-cyberpunk*.html`) ainda não é aceito pelo app — a ficha da Fase 1.5 tem
      seu próprio formato `.json` nomeado (salvar/carregar já funcionam nesse novo formato).
      Mapear o array posicional do HTML para esse formato fica para depois, se for necessário.

### 0.5.4 — Regras da casa (variante cyberpunk) ✅
A campanha usa variantes que **divergem do 3D&T Alpha oficial**. O motor suporta as duas,
selecionáveis por sessão, e nunca assume a variante como padrão global.
- [x] Flag de sessão `variante: 'alpha' | 'cyberpunk'` — `VARIANTES` em `src/data/regras.js`.
- [x] `alpha`: FD = Armadura + Habilidade + 1d; PM = 5 × Resistência.
- [x] `cyberpunk`: FD = Resistência + Habilidade + Equipamento + 1d; FA = Habilidade + Força (ou
      PdF) + Equipamento + 1d; **sem magia** — PM viram **PA (Pontos de Ação) = Habilidade × 5**;
      sem vantagem única (todos humanos ou variantes humanas); bônus de equipamento de +1 a +3
      entrando explicitamente nas duas fórmulas.
- [x] Orçamento de criação de 9 pontos como preset da campanha (`PONTOS_CRIACAO.cyberpunk`); a
      barra livre de 5 a 20 do Alpha continua disponível em `PONTOS_CRIACAO.alpha`.
- [x] Constantes nomeadas em `/src/data/regras.js` — nenhuma fórmula solta em componente.

---

## Fase 1 — Motor de Regras (Engine) ✅
Objetivo: separar toda a lógica de regras do 3D&T em um módulo puro, sem UI, reutilizável tanto
pela ficha quanto pelo modo de jogo.
- [x] `engine/dice.js` — rolagem de 1d6 (e múltiplos dados, quando necessário).
- [x] `engine/combate.js` — cálculo de Força de Ataque, Força de Defesa, PV/PM/PA e condições
      (Perto da Morte, derrotado), respeitando a flag de variante da Fase 0.5.4.
- [x] `engine/testes.js` — testes de característica/perícia com bônus e redutores.
- [x] `engine/personagem.js` — funções puras para validar e recalcular uma ficha (saldo de pontos,
      teto de desvantagens, faixa 0-5 de características, recursos derivados).
- [x] `engine/habilidades.js` — contabilidade de custo em PA das habilidades especiais do catálogo
      (pode ativar / ativar). O efeito mecânico específico de cada habilidade (duração, condições
      impostas, alvos válidos) continua descrito em `data/habilidades.js` como texto — resolução
      automática desses efeitos específicos fica para a Fase 4 (combate automatizado).
- [x] Testes unitários (Vitest) cobrindo as duas variantes (`npm test`; ver Fase 1.5 para a
      contagem atual, que cresceu com os ajustes de perícia e as funções base de combate).

Ainda não implementado nesta fase (não bloqueiam a Fase 2, mas ficam registrados):
`engine/narrator/*` completo (só o esqueleto de dados existe) e o importador de compatibilidade
com o `.json` posicional da ficha HTML antiga citado em 0.5.3.

---

## Fase 1.5 — UI de Ficha de Personagem ✅
Objetivo: primeira UI real do app (a Fase 1 só tinha o motor, sem tela nenhuma) — criação/edição de
ficha em React, reaproveitando o motor de regras e os catálogos de dados. Prioridade decidida pelo
usuário antes da Fase 2 (sessão multiplayer).
- [x] Decisão de estilização: **CSS puro** (CSS Modules + variáveis globais em
      `src/styles/tema.css`), reaproveitando a paleta e a linguagem visual já usada em
      `material/*.html` — sem introduzir Tailwind como dependência nova.
- [x] `src/hooks/usePersonagem.js` — estado da ficha em edição; saldo de pontos, validação e
      recursos derivados (PV/PA máx.) recalculados a cada mudança via `engine/personagem.js`.
- [x] `src/components/ficha/` — `FichaPersonagem.jsx` (container + toolbar salvar/carregar/limpar)
      e as seções: Características, Recursos, Dinheiro/Anotações, Equipamento/Ataques/Defesa
      (com FA/FD base calculados ao vivo via `combate.js`), Arquétipo/Habilidades (catálogo,
      filtrado por arquétipo escolhido + gerais), Perícias (11 áreas fixas), Vantagens/Desvantagens
      (catálogo, com aviso do teto de 3 pontos).
- [x] Salvar/carregar ficha em `.json` (formato novo, nomeado — não é o array posicional do HTML
      antigo, ver nota em 0.5.3).
- [x] Correção de lacuna encontrada no motor da Fase 1: `calcularSaldoPontos` não contabilizava o
      custo de perícias. Adicionado `CUSTO_PERICIA.ESPECIALIZACOES` em `regras.js` e a soma de
      custo de perícias em `engine/personagem.js`, com validação (não pode combinar "área completa"
      com especializações soltas na mesma área; máximo de 3 especializações soltas por área).
      `testarPericia` (`engine/testes.js`) também foi atualizado para a nova forma de
      `pericias: [{area, completa, especializacoes}]` em vez de uma lista plana de strings.
- [x] Adicionado `calcularForcaAtaqueBase` / `calcularForcaDefesaBase` em `engine/combate.js`
      (mesma fórmula das versões com dado, sem rolar 1d6) — mesma convenção já usada em
      `data/npcs.js` ("FA/FD já somadas, sem o 1d6"), reaproveitada pela ficha para mostrar totais
      ao vivo sem duplicar a fórmula na UI.
- [x] Testes: 40 testes Vitest (`npm test`), cobrindo os ajustes de perícia e as novas funções
      base de combate. Build (`npm run build`) e checagem visual manual (Playwright headless)
      sem erros de console.

Não implementado nesta fase (fica para depois, não bloqueia a Fase 2): importador do `.json`
posicional da ficha HTML antiga; múltiplas fichas por conta (hoje é uma ficha em memória, sem
persistência entre sessões do navegador — isso é trabalho de `SaveSystem`/Fase 6).

---

## Fase 2 — Estrutura de Sessão/Sala ⬜
Objetivo: permitir que várias pessoas entrem na mesma "mesa" via link/código.
- [ ] Modelo de dados de Sessão no Firestore: `sessao { codigo, jogadores[], estado, log[], variante }`.
- [ ] Tela "Criar Sala" (gera código) e "Entrar em Sala" (por código).
- [ ] Sincronização em tempo real do estado da sessão entre jogadores (listeners Firestore).
- [ ] Cada jogador entra com uma ficha (nova, importada da Fase 0 ou do `.json` da ficha HTML).

## Fase 3 — Motor do Mestre Semi-Automático ⬜
Objetivo: gerar cenas e eventos com pesos de probabilidade, e narrar de forma coerente.
- [ ] `engine/narrator/tabelas.js` — tabelas de eventos por categoria (combate, exploração, social,
      armadilha, tesouro, reviravolta) com pesos (comum/incomum/raro/épico).
- [ ] `engine/narrator/sorteio.js` — função de sorteio ponderado (weighted random) reutilizável.
- [ ] `engine/narrator/templates.js` — templates de texto narrativo com variáveis
      (`{nomePersonagem}`, `{local}`, `{inimigo}` etc.).
- [ ] `engine/narrator/motor.js` — orquestra: recebe contexto atual da cena → sorteia próximo
      evento → preenche template → retorna descrição + efeitos mecânicos.
- [ ] Encontros de combate sorteiam inimigos de `data/npcs.js` filtrando por `nivel`, conforme a
      soma de pontos do grupo (nível 1 em bando, nível 3 sozinho, nível 4 só em fim de arco).
- [ ] Configuração de "tom" da campanha (ex.: mais combate vs. mais social) que ajusta os pesos.
- [ ] Log narrativo persistido na sessão (histórico do que já aconteceu, para não repetir).
- [ ] `data/mapa/regioes.js` — as 41 regiões do mundo cyberpunk (lista fechada, ver
      `prompt-vscode-sistema-3dt.md`).
- [ ] `data/mapa/localidades.js` — no mínimo 4 localidades por região (41 × 4 = 164+ localidades),
      cada uma com tipo (comercial/perigo/social/marco/secreto), descrição base e ganchos
      narrativos.
- [ ] `engine/narrator/mapa.js` — seleciona região/localidade atual e injeta nas variáveis dos
      templates; ajusta pesos de categoria conforme o `tipo` da localidade.
- [ ] Ação de "viajar para [região]" dentro da sessão, atualizando o contexto do motor.

## Fase 4 — Resolução de Combate Automatizada ⬜
- [ ] Turnos automáticos: ordem de iniciativa (1d + Habilidade).
- [ ] Cálculo automático de FA x FD a cada ataque (jogador escolhe ação, sistema resolve o número).
- [ ] Atualização automática de PV/PA na ficha durante o combate.
- [ ] Condições especiais (Perto da Morte, 0 PV, indefeso, morte/desmaio) tratadas pelo motor.
- [ ] Interface de combate simplificada (botões de ação: Atacar, Defender, Esquivar, Usar Perícia,
      Usar Habilidade, Fugir).
- [ ] Paridade com o `painel-mestre-3dt.html`: a ordem de iniciativa da mesa virtual deve exportar
      para o mesmo formato que o painel do mestre já usa, para quem joga presencial.

## Fase 5 — Interface de Jogo (Mesa Virtual) ⬜
- [ ] Tela principal de sessão: log narrativo (estilo chat/feed), ficha resumida do personagem,
      botões de ação contextual.
- [ ] Indicadores visuais de PV/PA, status de combate.
- [ ] Modo espectador para quem quiser só assistir.
- [ ] Responsivo para celular (mesas podem ser jogadas em grupo com cada um no próprio aparelho).
- [ ] Botão "imprimir ficha" que gera a versão HTML A4 (retrato ou paisagem) já preenchida.

## Fase 6 — Persistência de Campanha ⬜
- [ ] Salvar progresso entre sessões (personagens evoluem, ganham Pontos de Experiência).
- [ ] Histórico de sessões anteriores por sala/campanha.
- [ ] Exportar resumo da campanha.
- [ ] Importar o `.json` do painel do mestre como estado inicial de uma campanha.

## Fase 7 — Narração com LLM (opcional, avançado) ⬜
- [ ] Substituir/complementar templates estáticos por geração de texto via API de LLM, mantendo o
      motor de pesos e regras mecânicas como estava (o LLM só "veste" a narrativa, não decide
      resultados mecânicos, para manter jogo balanceado e determinístico).
- [ ] Modo híbrido: mestre humano pode revisar/editar o que o LLM sugeriu antes de publicar na sessão.

## Fase 8 — Polimento ⬜
- [ ] Tema visual (arte, ícones, cores) inspirado no material da campanha: fundo claro, colunas,
      faixas coloridas por seção, tipografia monoespaçada nos rótulos.
- [ ] Sons/efeitos leves (opcional).
- [ ] Acessibilidade (contraste, tamanhos de fonte, navegação por teclado).
- [ ] PWA (instalável, funciona offline para fichas já carregadas).

---

## Backlog de ideias (sem fase definida ainda)
- Editor de campanhas customizadas (mestre humano cria suas próprias tabelas de eventos).
- Gerador de NPC por nível: informa o orçamento de pontos e o motor devolve uma ficha coerente.
- Modo solo (um jogador + mestre 100% automático, sem precisar de grupo).
- Integração com Discord (bot que narra em um canal de texto/voz).
- Sistema de conquistas/emblemas para incentivar jogo contínuo.

---

## Como atualizar este arquivo
Ao concluir um item, marque `[x]`. Ao concluir uma fase inteira, mude o status do título para ✅.
Se uma nova ideia surgir durante o desenvolvimento e não for prioridade imediata, jogue no
"Backlog de ideias" em vez de inflar as fases ativas.
