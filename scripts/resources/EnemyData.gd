class_name EnemyData
extends Resource

enum EnemyType { NORMAL, MINIBOSS, BOSS }

@export var enemy_id: String = ""
@export var enemy_name: String = ""
@export var enemy_type: EnemyType = EnemyType.NORMAL
@export var max_hp: int = 100
@export var atk: int = 10
@export var defense: int = 5
@export var move_speed: float = 100.0
@export var xp_reward: int = 20
@export var money_reward: int = 10
@export var sprite: Texture2D = null
