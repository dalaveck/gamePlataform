# IAcontext.md — Contexto do Projeto para IA

> Este arquivo existe para que qualquer assistente de IA (Claude, Copilot, etc.) que trabalhe neste
> projeto no futuro consiga entender rapidamente o que já foi decidido, por quê, e o que ainda falta.
> **Sempre leia este arquivo inteiro antes de propor mudanças de arquitetura.**
> **Sempre atualize este arquivo quando uma decisão importante for tomada.**

---

## 1. Visão geral do projeto

Um sistema de RPG jogável via navegador, baseado nas regras do **3D&T Alpha** (RPG brasileiro,
livro "Manual 3D&T Alpha", Jambô Editora), com um **Mestre/Narrador semi-automático**: o sistema
gera cenas, encontros e eventos usando tabelas de probabilidade ponderadas (algumas coisas são
mais prováveis de acontecer que outras), e resolve as regras mecânicas (testes, combate, PV/PM)
automaticamente, enquanto o conteúdo narrativo (texto, ambientação) é gerado a partir de templates
e, futuramente, de um modelo de linguagem.

O projeto nasceu de um gerador de fichas de personagem (ver seção 3) e está evoluindo para um
sistema completo de jogo.

---

## 2. Decisões de arquitetura já tomadas

| Decisão | Escolha | Motivo |
|---|---|---|
| Frontend | React (JSX) + Vite | Continuidade com o gerador de fichas já existente; web puro, sem overhead de Flutter Web |
| Estilização | **CSS puro** (CSS Modules + variáveis globais em `src/styles/tema.css`) — decidido na Fase 1.5 | Reaproveita a paleta e a linguagem visual já validada em `material/*.html` (fundo claro, ficha impressa, rótulos monoespaçados uppercase, seções com borda superior colorida); evita introduzir Tailwind como dependência nova sem necessidade |
| Backend / multiplayer | Firebase (Firestore + Auth anônima) | Não exige servidor próprio; salas em tempo real via listeners; fácil de hospedar (Vercel/Netlify + Firebase) |
| Dados do sistema (raças, vantagens, perícias, desvantagens) | Extraídos do manual oficial em PDF | Fidelidade às regras; ver `data/` no projeto da ficha |
| Dados/rolagens | 1d6 (padrão 3D&T) | Confirmado no manual |
| Hospedagem alvo | Web pública, qualquer dispositivo, sem instalação | Requisito do usuário: "jogável por qualquer pessoa que acessar via web" |
| Ambientação padrão | Cyberpunk, mapa fixo de 41 regiões, cada uma com no mínimo 4 localidades | Requisito do usuário; localidades alimentam os templates narrativos do motor do Mestre |

**Não usar Flutter** — decisão consciente para manter uma única base de código web e reaproveitar
o trabalho já feito na ficha em JSX.

---

## 3. Histórico do projeto (o que já existe)

### Fase 0 — Gerador de Fichas (concluído / prompt entregue)
- Arquivo de referência: `prompt-ficha-3dt-alpha.md`
- Funcionalidades: barra de pontos (5 a 20), compra de características, raça (vantagem única),
  vantagens, perícias, desvantagens (regra customizada: até 3 desvantagens dão pontos, extras
  além disso não dão bônus quando o saldo já está zerado), preview da ficha final, exportação/
  compartilhamento (Web Share API + fallbacks de mailto/WhatsApp/Drive).
- Esse gerador de ficha é a **base de dados de personagem** que o sistema de RPG completo vai
  consumir (o "personagem" criado ali passa a ser jogável dentro de uma sessão).

### Fase 1 — Sistema de RPG completo (em andamento)
- Ver `prompt-vscode-sistema-3dt.md` para o prompt completo enviado ao VS Code.
- Ver `ROADMAP.md` para as fases planejadas.

---

## 4. Regras do 3D&T Alpha confirmadas no manual (resumo técnico)

- Características (Força, Habilidade, Resistência, Armadura, Poder de Fogo): 0 a 5 na criação.
- PV = PM = 5 × Resistência (exceto Resistência 0 → 1 PV e 1 PM).
- Força de Ataque (corpo a corpo) = Força + Habilidade + 1d
- Força de Ataque (à distância) = Poder de Fogo + Habilidade + 1d
- Força de Defesa = Armadura + Habilidade + 1d
- Perícias: 2 pontos (completa) ou 1 ponto (3 especializações). 11 perícias no total.
- Personagem "morre/desmaia" com 0 PV; "Perto da Morte" quando PV ≤ Resistência.
- Pontuação de criação por nível de poder: Novato (5), Lutador (7), Campeão (10), Lenda (12) —
  o projeto usa uma barra livre de 5 a 20 pontos (mais flexível que o livro).

Consulte o PDF do manual (`3dt-alpha-manual-revisado-biblioteca-elfica.pdf`) para detalhes
completos de vantagens, desvantagens, raças e perícias — ele é a fonte de verdade.

---

## 5. O que é o "Mestre/Narrador semi-automático"

Conceito central do sistema: em vez de um humano narrando tudo, ou de um gerador 100%
aleatório/uniforme, o sistema usa **tabelas de eventos com pesos de probabilidade** (algumas
entradas são "comuns", outras "raras"), de forma que a sessão pareça ter ritmo e intenção, mesmo
sendo gerada automaticamente. Exemplo de estrutura de peso:

- Comum (~60% de chance): eventos de ambientação, encontros triviais, pistas menores.
- Incomum (~25%): encontros de combate médio, NPCs relevantes, escolhas morais.
- Raro (~10%): reviravoltas de história, itens mágicos, vilões secundários.
- Épico (~5%): eventos de clímax, grandes revelações, chefes.

O detalhamento técnico dessas tabelas está no prompt `prompt-vscode-sistema-3dt.md`, seção
"Motor do Mestre Semi-Automático". **Esse motor deve ser implementado como um módulo isolado
(`/src/engine/narrator/`), independente da UI**, para poder ser testado e ajustado sem mexer em
componentes visuais.

### 5.1 Mapa do mundo (cenário cyberpunk)

O mundo do jogo é dividido em um **mapa fixo de 41 regiões**, cada uma baseada em um conceito
clássico do universo cyberpunk (megacorporações, submundo, favelas verticais, hackers, IA,
biotecnologia etc.). **Cada região tem no mínimo 4 localidades visitáveis.** As localidades são a
matéria-prima usada para preencher as variáveis dos templates narrativos (ex.: `{local}`) e para
influenciar quais categorias de evento (combate, social, armadilha...) têm mais chance de ocorrer.

A lista fechada das 41 regiões e o padrão de dados (`regioes.js` / `localidades.js`) estão
detalhados em `prompt-vscode-sistema-3dt.md`, seção "Mapa do Mundo (41 Regiões Cyberpunk)". Não
altere essa lista de regiões sem atualizar este arquivo e o roadmap.

---

## 5.2 Variante "cyberpunk" da campanha (regras da casa)

A campanha piloto usa variantes que **divergem do Alpha oficial**. O motor deve suportar as duas,
com uma flag `variante: 'alpha' | 'cyberpunk'` por sessão, e nunca tratar a variante como padrão
global.

| Regra | Alpha oficial | Variante cyberpunk |
|---|---|---|
| Força de Ataque | Força (ou PdF) + Habilidade + 1d | Habilidade + Força (ou PdF) + **Equipamento** + 1d |
| Força de Defesa | **Armadura** + Habilidade + 1d | **Resistência** + Habilidade + **Equipamento** + 1d |
| Recurso gasto | PM = 5 × Resistência | **PA (Pontos de Ação) = Habilidade × 5** — não há magia |
| Raça / vantagem única | Existe | Removida: todos humanos ou variantes humanas |
| Pontuação de criação | 5 a 20 (barra livre) | Preset de **9 pontos** |
| Desvantagens | Até 3 dão pontos | Teto de **3 pontos** devolvidos |
| Equipamento | Vantagem/item | Bônus explícito de +1 a +3 nas duas fórmulas |

O material de mesa que documenta essa variante (fichas, resumo de regras, catálogo de habilidades,
bestiário de 20 NPCs em 4 níveis e painel do mestre) está em `/material/` — ver `material/README.md`.
Esses arquivos são a **fonte de conteúdo** para os dados da Fase 0.5.3 do roadmap (`data/habilidades.js`,
`data/npcs.js`, `data/arquetipos.js`). Ao alterar uma regra da casa, atualize a tabela acima, o
`ROADMAP.md` e os HTMLs correspondentes.

---

## 6. Convenções e boas práticas do projeto

- Nomes de arquivos e variáveis de domínio do jogo em português (ex.: `personagem`, `vantagens`,
  `pontosDeVida`), já que o público é brasileiro e os termos vêm do manual original.
- Nomes técnicos de infraestrutura (hooks, serviços, tipos genéricos) podem ficar em inglês, seguindo
  convenção usual de React.
- Toda regra numérica (custos, fórmulas, probabilidades) deve ter uma constante nomeada em
  `/src/data/` ou `/src/engine/`, nunca "número mágico" solto no meio do componente.
- Sempre que uma feature nova alterar a arquitetura, atualizar este arquivo (`IAcontext.md`) e o
  `ROADMAP.md`.

---

## 7. Perguntas em aberto / decisões pendentes

- [ ] O Mestre semi-automático vai (eventualmente) usar um LLM real para gerar texto narrativo, ou
      ficar só em templates com variáveis? (Sugestão: começar com templates, deixar hook pronto
      para plugar uma API de LLM depois.)
- [ ] Sessões vão ter um "mestre humano" opcional que pode sobrescrever o automático, ou é sempre
      100% automático?
- [ ] Limite de jogadores por sala.
- [ ] Persistência de campanha entre sessões (histórico de longo prazo) ou sessões avulsas por enquanto?

---

## 8. Como retomar o trabalho

1. Leia este arquivo inteiro.
2. Leia `ROADMAP.md` para ver a fase atual.
3. Leia `prompt-vscode-sistema-3dt.md` para o escopo técnico detalhado.
4. Confira o código em `/src/engine/narrator/` e `/src/data/` para ver o que já está implementado
   versus o que ainda é só especificação.
5. Antes de tomar decisões de arquitetura novas, registre aqui.

---

## 9. Estado do projeto (atualizado nesta sessão)

O repositório antes continha um jogo Godot 4 não relacionado (plataforma 2D coop). A pedido do
usuário, o conteúdo do Godot foi removido e o repositório passou a hospedar este projeto — não foi
criado um repositório novo.

### O que existe agora no repositório
- Scaffold Vite + React (`package.json`, `vite.config.js`, `index.html`, `src/main.jsx`,
  `src/App.jsx`) seguindo a arquitetura de `/src` descrita em `prompt-vscode-sistema-3dt.md`.
- `material/` — os HTMLs de mesa (fichas, regras, habilidades, NPCs, painel do mestre) e o
  `material/README.md`, copiados como estão.
- `src/data/regras.js` — constantes nomeadas das duas variantes (Alpha/cyberpunk): fórmulas de
  FA/FD, orçamento de pontos, teto de desvantagens, multiplicadores de PV/PM/PA.
- `src/data/habilidades.js`, `vantagens.js`, `desvantagens.js`, `arquetipos.js` — catálogo completo
  extraído de `material/habilidades-3dt-cyberpunk.html`.
- `src/data/npcs.js` — 21 NPCs extraídos de `material/npcs-3dt-cyberpunk-paisagem.html` (versão
  paisagem, que tem o bestiário completo; a versão retrato tem só 11).
- `src/data/mapa/regioes.js` — as 41 regiões completas (nome + tema, já estavam 100% especificadas
  no prompt original). `src/data/mapa/localidades.js` só tem as 3 regiões de exemplo (12
  localidades) — as outras 38 regiões ainda precisam de localidades, deixado para a Fase 3.
- `src/engine/` — `dice.js`, `combate.js`, `testes.js`, `personagem.js`, `habilidades.js`. Motor
  puro, sem dependência de React, com 40 testes Vitest em `src/engine/__tests__/` (`npm test`).
- **Decisão**: `engine/habilidades.js` não simula o efeito mecânico específico de cada habilidade
  (são ~30, cada uma com uma regra narrativa diferente). Ele só resolve o custo em PA (pode
  ativar / ativar). O efeito de cada uma fica como texto em `data/habilidades.js`, para o
  mestre/motor narrar — resolução mecânica automática completa é Fase 4.
- `src/engine/narrator/` **não foi criado ainda** — é Fase 3, fora do escopo desta sessão.

### Atualização — Fase 1.5 (UI de ficha de personagem)
Depois da Fase 1, o usuário pediu para publicar o app (ver seção 10) e priorizar a UI de ficha
antes da sessão multiplayer. O que mudou:
- `src/App.jsx` **não é mais um placeholder** — renderiza `<FichaPersonagem />`. Primeira UI real
  do app.
- `src/hooks/usePersonagem.js` — hook com o estado da ficha em edição (características, buffs,
  recursos atuais, dinheiro, equipamento, ataques/defesas dinâmicos, arquétipo, habilidades,
  vantagens, desvantagens, perícias, anotações) e as funções para editá-lo. Saldo de pontos,
  validação e PV/PA máximos são recalculados a cada mudança chamando `engine/personagem.js`
  diretamente — o hook não duplica nenhuma regra, só orquestra estado.
- `src/components/ficha/` — deixou de ser uma pasta vazia. `FichaPersonagem.jsx` é o container
  (toolbar salvar/carregar/limpar, cabeçalho, banner de saldo/erros) e delega a cada seção
  (`SecaoCaracteristicas`, `SecaoRecursos`, `SecaoCombate`, `SecaoArquetipoHabilidades`,
  `SecaoPericias`, `SecaoVantagensDesvantagens`, `SecaoDinheiroAnotacoes`). Estilo em
  `Ficha.module.css` (CSS Modules), compartilhado entre as seções.
- **Correção retroativa na Fase 1**: `calcularSaldoPontos` não contava o custo de perícias — foi
  corrigido (ver `ROADMAP.md` Fase 1.5) junto com uma mudança de forma de dado: `personagem.pericias`
  passou de lista de strings para `[{area, completa, especializacoes}]`. Isso quebra qualquer
  personagem de teste/exemplo que ainda use a forma antiga — não há dados salvos reais para
  migrar ainda (o app não tinha persistência), então não foi necessário shim de compatibilidade.
- `src/engine/combate.js` ganhou `calcularForcaAtaqueBase`/`calcularForcaDefesaBase` (mesma fórmula,
  sem rolar o 1d6) para a ficha mostrar totais ao vivo — mesma convenção de "sem o 1d6" que
  `data/npcs.js` já usava nos dados do bestiário.
- `src/data/pericias.js` (novo) — `AREAS_PERICIA`, as 11 áreas fixas do manual.
- Export/import de ficha usa um `.json` novo, nomeado (`{v, variante, personagem}}`) — **não** é
  compatível com o `.json` posicional que os botões "Salvar/Carregar" de `material/ficha-3dt-*.html`
  geram (aquele é um array de valores na ordem do DOM). Migrar um desses arquivos antigos para o
  app ainda não é suportado (ver ROADMAP 0.5.3).
- Verificação: `npm test` (40 testes), `npm run build`, e checagem visual manual com Playwright
  headless (instalado com `--no-save`, não é dependência do projeto) — sem erros de console,
  cálculo de saldo conferido preenchendo uma ficha de exemplo.
- `src/services/` continua vazia — é Firebase/sessão, Fase 2.

## 10. Deploy — gametest.rondobyte.com.br

Decidido com o usuário: hospedagem na **Vercel** (conectada ao repositório GitHub), domínio
`rondobyte.com.br` com DNS gerenciado na **Hostinger**. A Vercel detecta Vite automaticamente, sem
`vercel.json` necessário. Fluxo (feito pelo usuário no painel de cada serviço — esta sessão não tem
acesso a nenhum dos dois):
1. Conectar `dalaveck/gamePlataform` num projeto novo na Vercel.
2. Produção segue o branch padrão do repo (`main`) — mergear a PR de cada fase para produção
   atualizar. Outros branches/PRs geram Preview Deployments automáticos.
3. Settings → Domains → adicionar `gametest.rondobyte.com.br`; a Vercel indica o valor exato do
   CNAME (tipicamente `cname.vercel-dns.com`).
4. Criar esse CNAME na Zona DNS da Hostinger (hPanel → Domínios → `rondobyte.com.br`), host
   `gametest`.
5. SSL é automático (Let's Encrypt) assim que o DNS propaga.

### Próximo passo sugerido
Seguir `ROADMAP.md`: Fase 2 (sessão/sala com Firebase) é a próxima fase de feature. Deploy
(seção 10 acima) é independente e pode ser feito a qualquer momento — cada push em `main` já fica
publicado automaticamente depois do primeiro setup.
