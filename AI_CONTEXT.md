# AI_CONTEXT — Plataforma Coop

## Stack
- **Engine:** Godot 4.x
- **Linguagem:** GDScript com tipagem estática obrigatória
- **Multiplayer:** MultiplayerAPI nativo (ENet) com RPCs
- **Padrão:** Component-based + Resource data classes + Autoloads
- **Tipo:** Plataforma 2D, coop até 4 jogadores

---

## Personagens
| Classe    | Recurso principal | Stat chave     | Estilo           |
|-----------|-------------------|----------------|------------------|
| Warrior   | SP                | STR, CON       | Melee / espada   |
| Cleric    | MP                | SPI            | Magias / suporte |
| Archer    | SP                | SKL, STR       | Ranged / flechas |

Jogadores podem criar múltiplos personagens por conta.

---

## Fórmulas de Stats

```
HP_max  = 100 + (CON * 20)   |  Defesa   = 5 + (CON * 3)
MP_max  = 50  + (SPI * 15)   |  M.Power  = SPI * 5
SP_max  = 80  + (SKL * 10)   |  Agilidade = 1.0 + (SKL * 0.05)
ATK     = 10  + (STR * 5)
```

---

## Recursos (SP e MP)

- **SP:** Dash (20), corrida contínua (15/seg), skills de Warrior e Archer
- **MP:** Todas as magias do Cleric
- SP regenera 10/seg | MP regenera 2/seg

---

## Mecânicas de Plataforma
- Pulo duplo (usa 2ª vez do counter)
- Dash (gasta SP, MovementComponent.try_dash)
- Wall-jump ao estar em wall-slide (gasta contador de pulo)
- Wall-slide desacelera queda

---

## Economia
- **XP:** por personagem ativo (CharacterData.experience) — quem mata leva
- **Dinheiro:** da conta global (SaveSystem.account_money) — vai para todos
- Fonte: EnemyData.xp_reward e EnemyData.money_reward
- Distribuição via XPComponent.distribute_rewards()

---

## Estrutura de Mapas
- Cada mapa tem dificuldade (EASY/NORMAL/HARD/EXTREME)
- Cada mapa tem um MiniBoss e um Boss
- Boss na fase 3 (< 33% HP) = modo enraivecido
- Conclusão do mapa emite EventBus.map_completed

---

## Autoloads (Singletons)
| Nome           | Responsabilidade                              |
|----------------|-----------------------------------------------|
| EventBus       | Signals desacoplados entre todos os sistemas  |
| GameManager    | Estado global do jogo (enum GameState)        |
| NetworkManager | Criação/entrada de sala, RPCs de sincronismo  |
| SaveSystem     | Persistência de conta e personagens (JSON)    |
| SessionData    | Dados voláteis da sessão atual (sem salvar)   |

---

## Componentes por Personagem
- **StatsComponent** — HP/MP/SP, atributos, cálculo derivado, regen
- **MovementComponent** — andar, correr, pulo duplo, dash, wall-jump
- **CombatComponent** — ataque básico, uso de skills, cooldowns
- **XPComponent** — (no inimigo) distribui XP/dinheiro ao morrer
- **LootComponent** — (no inimigo) rola drops de itens

---

## Convenções de Código
- Tipagem estática em **tudo** (`var x: float = 0.0`)
- Prefixo `_` para membros e funções privadas
- Unique nodes com `%NomeDono` (nunca `$A/B/C`)
- Comunicação entre nós **sempre** via signals ou EventBus
- Resources (`.tres`) para todos os dados de jogo
- RPCs com modo e confiabilidade explícitos

---

## O que NÃO fazer
- `var x` sem tipo → erro de convenção
- Acessar `SaveSystem` ou `SessionData` dentro de componentes
  (usar signals e deixar o pai fazer a ponte)
- Lógica de rede dentro das cenas de personagem
- Herança profunda: preferir composição via componentes

---

## Arquivos principais
```
scripts/autoloads/
  EventBus.gd       ← signals globais
  GameManager.gd    ← estados do jogo
  NetworkManager.gd ← ENet, RPCs
  SaveSystem.gd     ← persistência
  SessionData.gd    ← sessão atual

scripts/resources/
  CharacterData.gd  ← dados do personagem
  ItemData.gd       ← itens e equipamentos
  EnemyData.gd      ← dados dos inimigos
  MapData.gd        ← dados dos mapas
  SkillData.gd      ← habilidades

scripts/components/
  StatsComponent.gd
  MovementComponent.gd
  CombatComponent.gd
  XPComponent.gd
  LootComponent.gd

scripts/characters/
  BaseCharacter.gd  ← lógica comum
  Warrior.gd
  Cleric.gd
  Archer.gd

scripts/enemies/
  BaseEnemy.gd
  MiniBoss.gd
  Boss.gd
```
