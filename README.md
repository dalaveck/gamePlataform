# PlatformerCoop

Plataformer 2D cooperativo com suporte a multijogador via rede local (LAN).  
Desenvolvido em **Godot 4.x** com **GDScript**.

---

## Índice

1. [Visão Geral](#visão-geral)
2. [Controles](#controles)
3. [Fluxo do Jogo](#fluxo-do-jogo)
4. [Arquitetura do Projeto](#arquitetura-do-projeto)
5. [Sistemas do Jogo](#sistemas-do-jogo)
6. [Personagens Jogáveis](#personagens-jogáveis)
7. [Inimigos](#inimigos)
8. [Mapas](#mapas)
9. [Equipamentos e Itens](#equipamentos-e-itens)
10. [Progressão e Atributos](#progressão-e-atributos)
11. [Multiplayer](#multiplayer)
12. [Como Adicionar Conteúdo](#como-adicionar-conteúdo)
13. [Arquivos de Configuração JSON](#arquivos-de-configuração-json)
14. [Estrutura de Arquivos](#estrutura-de-arquivos)

---

## Visão Geral

- **Gênero:** Plataformer 2D de ação cooperativo
- **Jogadores:** 1 a 4 (LAN)
- **Motor:** Godot 4.x
- **Linguagem:** GDScript
- **Save:** `user://saves/account.json` (dinheiro, personagens, equipamentos)

---

## Controles

### Movimentação

| Tecla | Ação |
|-------|------|
| `A` / `←` | Mover para a esquerda |
| `D` / `→` | Mover para a direita |
| `Espaço` | Pular (pode pular 2x no ar) |
| `Shift` | Correr |
| `Ctrl` | Dash |
| `Z` / Click Esquerdo | Atacar |
| `X` | Habilidade 1 |
| `C` | Habilidade 2 |
| `V` | Habilidade 3 |

### Interface

| Tecla | Ação |
|-------|------|
| `H` | Abrir tela de Atributos (distribuir pontos de nível) |
| `I` | Abrir Inventário / Loja (equipar e comprar itens) |
| `ESC` | Menu de Pausa (configurações, menu principal, resetar) |

### Mecânicas de Plataforma

- **Pulo Duplo:** Pressione Espaço novamente no ar
- **Wall Jump:** Pressione Espaço enquanto está na parede
- **Dash:** `Ctrl` — invulnerabilidade breve durante o dash

---

## Fluxo do Jogo

```
Menu Principal
    ↓ (criar sala / entrar em sala LAN)
Lobby
    ↓ (todos prontos)
Seleção de Mapa  (somente host)
    ↓ (host escolhe o mapa)
Jogo em Campo  ←── respawn na killzone
    ↓ (boss derrotado)        ↓ (todos os jogadores morrem)
  Vitória                   Game Over
    ↓                           ↓
         Menu Principal
```

**Importante:** Quando o boss é derrotado, `EventBus.boss_defeated` dispara e `GameManager` muda para o estado `VICTORY`.

---

## Arquitetura do Projeto

### Autoloads (Singletons)

São carregados automaticamente ao iniciar o jogo, nesta ordem:

| Autoload | Arquivo | Responsabilidade |
|----------|---------|-----------------|
| `EventBus` | `scripts/autoloads/EventBus.gd` | Hub central de sinais (eventos de combate, progressão, mapa, lobby, UI) |
| `GameManager` | `scripts/autoloads/GameManager.gd` | Máquina de estados do jogo (6 estados, transição de cenas) |
| `NetworkManager` | `scripts/autoloads/NetworkManager.gd` | Rede ENet + descoberta de salas via UDP broadcast |
| `ItemDatabase` | `scripts/autoloads/ItemDatabase.gd` | Banco de itens carregado de `data/config/items.json` |
| `SaveSystem` | `scripts/autoloads/SaveSystem.gd` | Persistência da conta (dinheiro, personagens, equipamentos) |
| `SessionData` | `scripts/autoloads/SessionData.gd` | Dados voláteis da sessão (peer IDs, personagem ativo, lobby) |
| `VFX` | `scripts/autoloads/VFX.gd` | Efeitos visuais procedurais (partículas, números de dano) |

> **Atenção:** `ItemDatabase` deve estar listado **antes** de `SaveSystem` no `project.godot`, pois o `SaveSystem` usa o `ItemDatabase` ao desserializar saves.

### Camadas de Física (Physics Layers)

| Layer | Nome | Uso |
|-------|------|-----|
| 1 | `world` | Geometria estática (chão, paredes, plataformas) |
| 2 | `players` | Colisão dos personagens |
| 3 | `enemies` | Colisão dos inimigos |
| 4 | `player_attacks` | Hitboxes de ataque dos jogadores |
| 5 | `enemy_attacks` | Áreas de ataque dos inimigos |

---

## Sistemas do Jogo

### Stats e Atributos

**Atributos base** (modificáveis pelo jogador ao subir de nível):

| Atributo | Efeito |
|----------|--------|
| `strength` (Força) | ATQ = `10 + strength × 5` |
| `skill` (Habilidade) | SP Máx = `80 + skill × 10`; Agilidade = `1.0 + skill × 0.05` |
| `constitution` (Constituição) | HP Máx = `100 + constitution × 20`; Defesa = `5 + constitution × 3` |
| `spirit` (Espírito) | MP Máx = `50 + spirit × 15`; Poder Mágico = `spirit × 5` |

Fórmulas implementadas em: `scripts/components/StatsComponent.gd → _derive_stats()`

**Bônus de equipamentos** são somados *após* as fórmulas base.

### Regeneração Passiva

Só ativa quando não há inimigos a menos de 280px:

| Recurso | Taxa |
|---------|------|
| HP | +5 por segundo |
| SP | +10 por segundo |
| MP | +2 por segundo |

### Fórmula de Dano

```
dano_aplicado = max(1, dano_recebido - defense)
```

### Progressão de Nível

- XP necessário: `xp_base[nível N] = 100 × 1.2^(N-1)`
- Ao subir de nível: +3 pontos de atributo
- Implementado em: `SaveSystem._on_xp_gained()`

### Killzone (Queda)

Queda no vazio causa `25 + defense` de dano e reposiciona o personagem no primeiro spawn point.

### Componentes (ECS-like)

Cada personagem tem componentes filhos:

| Componente | Script | Função |
|------------|--------|--------|
| `StatsComponent` | `scripts/components/StatsComponent.gd` | HP/MP/SP, stats derivados, regen, dano, cura |
| `MovementComponent` | `scripts/components/MovementComponent.gd` | Velocidade, pulo, dash, wall-jump, gravidade |
| `CombatComponent` | `scripts/components/CombatComponent.gd` | Cooldowns de ataque e habilidades, consumo de SP/MP |
| `XPComponent` | `scripts/components/XPComponent.gd` | Distribuição de XP e dinheiro ao matar inimigos |
| `LootComponent` | `scripts/components/LootComponent.gd` | Drops aleatórios de itens |

---

## Personagens Jogáveis

### Guerreiro (`Warrior`)

- **Atributos base:** FOR 5 · HAB 3 · CON 4 · ESP 1
- **Armas:** Espadas, Machados
- **Armadura:** Pesada (bônus de defesa)
- **Habilidades:**
  - `Z` Ataque básico com espada (custa SP)
  - `X` Ataque Giratório — atinge ambos os lados (custa SP + MP)
  - `C` Super Ataque — 3× dano, knockback penetrante (custa SP + MP)
  - `V` Buff Proteção — redução de 50% de dano por 10s (custa MP)

### Clérigo (`Cleric`)

- **Atributos base:** FOR 2 · HAB 2 · CON 3 · ESP 6
- **Armas:** Varinhas, Cajados
- **Armadura:** Roupões leves
- **Habilidades:**
  - `Z` Raio Sagrado básico (custa MP)
  - `X` Cura Maior — restaura 30% HP e 50% SP (cura aliados em 200px) (custa MP)
  - `C` Bola de Fogo — 3× poder mágico (custa MP)
  - `V` Maldição Imperdoável — projétil que ricocheteia (custa MP)

### Arqueiro (`Archer`)

- **Atributos base:** FOR 3 · HAB 5 · CON 2 · ESP 2
- **Armas:** Arcos, Bestas
- **Armadura:** Couro leve (bônus de habilidade)
- **Habilidades:**
  - `Z` Flecha básica (custa SP)
  - `X` Flechas Múltiplas — 5 flechas com dispersão de 7° (custa SP + MP)
  - `C` Flecha Avassaladora — atravessa inimigos (custa SP + MP)
  - `V` Flecha Explosiva — dano em área ao impacto (custa SP + MP)

---

## Inimigos

| Inimigo | Tipo | Mapa | HP | ATQ | DEF | XP | Ouro |
|---------|------|------|----|-----|-----|----|------|
| Slime | Normal | Map01 | 60 | 12 | 2 | 25 | 8 |
| Galinha Voadora | Normal | Map01 | 45 | 10 | 1 | 20 | 5 |
| Lobo de Gelo | Normal | Map02 | 85 | 18 | 5 | 50 | 20 |
| Águia de Gelo | Normal | Map02 | 70 | 16 | 3 | 45 | 18 |
| Ogro da Floresta | Miniboss | Map01 | 200 | 22 | 8 | 100 | 50 |
| Yeti de Gelo | Miniboss | Map02 | 950 | 42 | 18 | 420 | 200 |
| Guardião da Floresta | Boss | Map01 | 500 | 35 | 12 | 300 | 150 |
| Dragão de Gelo | Boss | Map02 | 2800 | 60 | 22 | 1400 | 700 |

**Scripts de IA:**
- `Slime.gd` — patrulha, vira em paredes/bordas (EdgeRay), persegue ao detectar
- `FlyingEnemy.gd` — voa, bate asas para subir, plana perto da altura máxima
- `MiniBoss.gd` — fase 2 ao atingir 50% HP (mais rápido e agressivo)
- `Boss.gd` — múltiplas fases, ataque de área especial, enraivece abaixo de 33% HP

---

## Mapas

### Map01 — Floresta Sombria
- **Largura:** ~3200px
- **Nível recomendado:** 1
- **Dificuldade:** Fácil
- **Inimigos:** 5 Galinhas Voadoras, 1 Ogro (miniboss), 1 Guardião (boss)
- **Background:** Tons verdes de floresta (parallax com 2 camadas)

### Map02 — Terra do Gelo
- **Largura:** ~5750px
- **Nível recomendado:** 5
- **Dificuldade:** Normal
- **Inimigos:** 7 Lobos, 5 Águias, 1 Yeti (miniboss), 1 Dragão (boss)
- **Background:** Azul gelo escuro (parallax com 2 camadas)
- **Plataformas:** 15 plataformas de gelo, 3 paredes para wall-jump, 5 segmentos de chão com buracos

**Parallax:** Controlado por `BaseMap._process()` — camada 1 move a 0.18× da câmera, camada 2 a 0.38×.

---

## Equipamentos e Itens

### Slots de Equipamento (7 slots por personagem)

| Slot | Tipos de Itens |
|------|---------------|
| Arma | Classe específica (espada/machado/varinha/cajado/arco/besta) |
| Roupa/Armadura | Classe específica (armadura pesada/roupão/couro) |
| Capacete/Elmo | Classe específica |
| Botas | Universal |
| Bracelete | Universal |
| Colar | Universal |
| Anel | Universal |

### Bônus de Itens

Itens podem conceder:
- `bonus_atk` — Ataque adicional
- `bonus_defense` — Defesa adicional
- `bonus_magic_power` — Poder mágico adicional
- `bonus_strength` — Força adicional
- `bonus_skill` — Habilidade adicional
- `bonus_constitution` — Constituição adicional
- `bonus_spirit` — Espírito adicional

### Progressão de Equipamentos (por classe)

Cada classe tem 3 níveis de equipamento:

| Nível | Preço médio | Quando conseguir |
|-------|------------|-----------------|
| Básico | 55–80 ouro | Logo no início (Nv. 1–3) |
| Intermediário | 130–175 ouro | Após alguns inimigos (Nv. 3–6) |
| Avançado | 260–440 ouro | Após miniboss / bosses |

### Onde Editar Itens

**Para modificar itens existentes ou adicionar novos:**
→ `data/config/items.json`

O `ItemDatabase` lê este arquivo automaticamente ao iniciar.

---

## Progressão e Atributos

### Tela de Atributos (tecla `H`)

- Exibe barra de XP, nível atual e pontos disponíveis
- Botões `+` e `-` para distribuir pontos em cada atributo
- Preview dos stats derivados em tempo real (sem equipamentos)
- Botão **Aplicar** confirma e salva

### Inventário / Loja (tecla `I`)

**Painel esquerdo:** 7 slots equipados com botão `X` para desequipar

**Aba Loja:**
- Lista todos os itens disponíveis para a classe do personagem
- Mostra tipo, nome e preço em ouro
- Botão Comprar fica desativado se ouro insuficiente
- Item vai direto ao slot se estiver vazio; caso contrário, vai para o inventário

**Aba Inventário:**
- Itens não equipados
- Botão **Equipar** — substitui o item atual no slot (o antigo vai para o inventário)
- Botão **Vender** — remove o item e devolve 50% do preço em ouro

### Menu de Pausa (tecla `ESC`)

- Slider de Volume Geral
- Slider de Volume Música
- Toggle de Tela Cheia
- **Continuar** — fecha o menu
- **Menu Principal** — volta ao menu sem apagar save
- **Resetar Jogo** — apaga toda a conta e volta ao menu

---

## Multiplayer

- **Protocolo:** ENet via `ENetMultiplayerPeer`
- **Porta:** 7777 (jogo), 7778 (descoberta UDP)
- **Máximo:** 4 jogadores
- **Topologia:** Host-Client (host controla IA dos inimigos)

### Descoberta de Salas na LAN

O host transmite um pacote UDP broadcast a cada 1 segundo com o formato:
```
PLATCOOP_V1|Sala de <nome_do_jogador>
```
Clientes na mesma rede escutam na porta 7778 e listam as salas disponíveis.  
Salas desaparecem após 4 segundos sem broadcast.

### Sincronização

| Dado | Método |
|------|--------|
| Nome do jogador | `@rpc sync_player_name` |
| Personagem escolhido | `@rpc sync_character_data` |
| Estado "pronto" no lobby | `@rpc sync_ready_state` |
| Iniciar jogo | `@rpc start_game` (authority → todos) |
| Dano ao jogador | `receive_damage.rpc` (any_peer, call_local) |
| Morte do inimigo | RPC via BaseEnemy (authority, call_local) |

---

## Como Adicionar Conteúdo

### Adicionar um Novo Item

1. Abra `data/config/items.json`
2. Adicione um novo objeto no array seguindo o padrão:
```json
{
  "id": "meu_item_unico",
  "name": "Nome do Item",
  "type": "WEAPON",
  "restriction": "WARRIOR",
  "price": 200,
  "bonus_atk": 30,
  "bonus_strength": 2
}
```
- `type`: `WEAPON`, `ARMOR`, `HELMET`, `BOOTS`, `BRACELET`, `NECKLACE`, `RING`, `CONSUMABLE`
- `restriction`: `ALL`, `WARRIOR`, `CLERIC`, `ARCHER`
- Campos de bônus omitidos valem 0

### Adicionar um Novo Inimigo

1. Crie um arquivo `.tres` em `data/enemies/` baseado em um existente (ex: `slime.tres`)
2. Crie uma cena `.tscn` em `scenes/enemies/` baseada em `Slime.tscn` ou `FlyingChicken.tscn`
3. No `.tscn`, mude o `enemy_data` para o novo `.tres`
4. Adicione instâncias da cena no mapa desejado (`scenes/maps/Map01.tscn` ou `Map02.tscn`)

### Adicionar um Novo Mapa

1. Crie um arquivo `.tres` em `data/maps/` (campos: `map_id`, `map_name`, `difficulty`, `scene_path`, `recommended_level`, `miniboss_id`, `boss_id`)
2. Crie a cena do mapa em `scenes/maps/` usando `BaseMap` como script
3. Adicione o caminho do `.tres` no array `MAP_RESOURCES` em `scripts/ui/MapSelect.gd`

### Alterar Stats de uma Classe

1. Abra `data/config/classes.json`
2. Modifique os valores em `base_stats` para a classe desejada
3. O jogo aplica esses valores ao criar um personagem novo (`SaveSystem.create_character`)

### Alterar Fórmulas de Stats

As fórmulas estão em `scripts/components/StatsComponent.gd → _derive_stats()`:
```gdscript
max_hp      = 100 + (constitution * 20)
defense     = 5   + (constitution * 3)
max_mp      = 50  + (spirit * 15)
magic_power = spirit * 5
max_sp      = 80  + (skill * 10)
agility     = 1.0 + (skill * 0.05)
atk         = 10  + (strength * 5)
```
Consulte também `data/config/game_constants.json` para referência.

---

## Arquivos de Configuração JSON

Todos em `data/config/`:

| Arquivo | Carregado por | O que modifica |
|---------|--------------|----------------|
| `items.json` | `ItemDatabase.gd` | Todos os itens do jogo (stats, preço, restrição de classe) |
| `classes.json` | `SaveSystem.gd` | Stats base de cada classe ao criar personagem |
| `game_constants.json` | — (referência) | Fórmulas de stats, regen, XP, dano — documenta as constantes do código |
| `enemies_reference.json` | — (referência) | Catálogo de todos os inimigos com stats e localização |

---

## Estrutura de Arquivos

```
gamePlataform/
│
├── assets/art/                    # Sprites SVG
│   ├── warrior.svg, cleric.svg, archer.svg
│   ├── slime.svg, chicken.svg
│   ├── ice_wolf.svg, ice_eagle.svg, ice_yeti.svg, ice_dragon.svg
│   └── ...
│
├── data/
│   ├── config/                    # ← Configuração em JSON (editável)
│   │   ├── items.json             # Todos os itens (lido pelo ItemDatabase)
│   │   ├── classes.json           # Stats base das classes (lido pelo SaveSystem)
│   │   ├── game_constants.json    # Referência de formulas e constantes
│   │   └── enemies_reference.json # Catálogo de inimigos
│   ├── enemies/                   # Stats de inimigos (.tres)
│   └── maps/                      # Metadados de mapas (.tres)
│
├── scenes/
│   ├── characters/warrior|cleric|archer/  # Cenas dos personagens
│   ├── enemies/base|flying|miniboss|boss/  # Cenas dos inimigos
│   ├── maps/                      # Map01.tscn, Map02.tscn
│   ├── projectiles/               # Arrow, Fireball, etc.
│   └── ui/                        # HUD, MainMenu, Lobby, etc.
│
├── scripts/
│   ├── autoloads/                 # Singletons globais
│   │   ├── EventBus.gd            # Hub de sinais
│   │   ├── GameManager.gd         # Máquina de estados
│   │   ├── NetworkManager.gd      # Multiplayer ENet
│   │   ├── ItemDatabase.gd        # Carrega items.json
│   │   ├── SaveSystem.gd          # Persistência (user://saves/)
│   │   ├── SessionData.gd         # Dados voláteis de sessão
│   │   └── VFX.gd                 # Efeitos visuais
│   ├── characters/
│   │   ├── BaseCharacter.gd       # Plataformer base (dash, wall-jump, knockback)
│   │   ├── Warrior.gd             # Melee — skills giratório/super/proteção
│   │   ├── Cleric.gd              # Magia — cura/bola de fogo/maldição
│   │   └── Archer.gd              # Ranged — multiflechas/penetrante/explosiva
│   ├── components/
│   │   ├── StatsComponent.gd      # HP/MP/SP, formulas, regen, dano, cura
│   │   ├── MovementComponent.gd   # Velocidade, pulo, dash, wall-jump
│   │   ├── CombatComponent.gd     # Cooldowns, consumo SP/MP
│   │   ├── XPComponent.gd         # XP e dinheiro ao matar inimigos
│   │   └── LootComponent.gd       # Drops de itens
│   ├── enemies/
│   │   ├── BaseEnemy.gd           # IA: patrol/chase/attack/dead
│   │   ├── Slime.gd               # Inimigo terrestre básico
│   │   ├── FlyingEnemy.gd         # Inimigo aéreo
│   │   ├── MiniBoss.gd            # Miniboss (2 fases)
│   │   └── Boss.gd                # Boss (múltiplas fases, ataque de área)
│   ├── maps/
│   │   └── BaseMap.gd             # Spawn, parallax, killzone
│   ├── resources/
│   │   ├── CharacterData.gd       # Recurso de personagem (atributos, slots, inventário)
│   │   ├── EnemyData.gd           # Recurso de inimigo (stats, XP, dinheiro)
│   │   ├── ItemData.gd            # Recurso de item (tipo, bônus, preço, restrição)
│   │   ├── MapData.gd             # Recurso de mapa (id, dificuldade, cena, boss)
│   │   └── SkillData.gd           # Recurso de habilidade (custo, multiplicador, cooldown)
│   └── ui/
│       ├── HUD.gd                 # Barras HP/MP/SP, nível, dinheiro, skill bar
│       ├── PauseMenu.gd           # ESC — audio, fullscreen, sair, resetar
│       ├── StatsScreen.gd         # H — distribuir pontos de atributo
│       ├── InventoryShopScreen.gd # I — inventário e loja
│       ├── MainMenu.gd            # Tela inicial, criar/entrar sala
│       ├── LobbyRoom.gd           # Lobby pré-jogo, escolha de classe
│       ├── MapSelect.gd           # Seleção de mapa (somente host)
│       ├── SkillBar.gd            # Barra de 4 habilidades
│       └── EndScreen.gd           # Base para GameOver / Vitória
│
└── project.godot                  # Config do Godot (autoloads, inputs, camadas)
```

---

## Variáveis de Ambiente / Save

O jogo salva em:
- **Arquivo:** `user://saves/account.json`
- **Conteúdo:** nome da conta, ouro, array de personagens (com equipamentos e inventário)
- **Localização no SO:**
  - Windows: `%APPDATA%/Godot/app_userdata/PlatformerCoop/saves/`
  - Linux: `~/.local/share/godot/app_userdata/PlatformerCoop/saves/`

Para **resetar o save**, delete o arquivo `account.json` ou use o botão "Resetar Jogo" no menu de pausa.
