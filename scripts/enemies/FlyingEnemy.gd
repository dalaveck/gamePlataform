class_name FlyingEnemy
extends BaseEnemy

## Inimigo voador estilo "galinha": dá pequenos pulos (flaps) para subir,
## ao atingir uma altura máxima começa a planar (gravidade reduzida) e
## pula novamente ao se aproximar do chão. A altura é limitada para que o
## guerreiro (melee) ainda consiga acertá-lo em pé na plataforma.

const FLAP_IMPULSE   := -260.0  ## força de cada flap (negativo = subir)
const GLIDE_GRAVITY  := 240.0   ## gravidade reduzida ao planar (chicken-like)
const MAX_FLY_HEIGHT := 96.0    ## altura máx. acima do chão de referência
const FLAP_INTERVAL  := 0.85    ## intervalo entre flaps no ar
const REFLAP_HEIGHT  := 0.45    ## fração da altura máx. para voltar a flapar

var _vy: float            = 0.0     ## velocidade vertical própria
var _ground_y: float      = 0.0     ## Y do último chão tocado (referência)
var _has_ground_ref: bool = false
var _flap_timer: float    = 0.0
var _patrol_dir: float    = 1.0

func _ready() -> void:
	super._ready()
	current_state = EnemyState.PATROL

# ─── Patrulha voando de um lado para o outro ───────────────
func _do_patrol(delta: float) -> void:
	if is_on_wall():
		_patrol_dir *= -1.0
	_fly(delta, _patrol_dir)
	sprite.flip_h = _patrol_dir < 0.0

# ─── Persegue o alvo voando (ignora beiradas, atravessa vãos) ─
func _do_chase(delta: float) -> void:
	if _target == null:
		current_state = EnemyState.PATROL
		return
	var dir := signf(_target.global_position.x - global_position.x)
	if dir == 0.0:
		dir = _patrol_dir
	sprite.flip_h = dir < 0.0
	_fly(delta, dir)

# ─── Núcleo do voo ─────────────────────────────────────────
func _fly(delta: float, dir: float) -> void:
	_update_ground_ref()
	velocity.x = dir * enemy_data.move_speed

	var height := (_ground_y - global_position.y) if _has_ground_ref else 0.0

	# Ao tocar o chão, zera a queda para iniciar um novo flap limpo
	if is_on_floor() and _vy > 0.0:
		_vy = 0.0

	# Teto de altura: ao subir além do limite, para de subir e começa a planar
	if _vy < 0.0 and height >= MAX_FLY_HEIGHT:
		_vy = 0.0

	# Gravidade reduzida (planeio)
	_vy += GLIDE_GRAVITY * delta

	# Bate as asas de novo quando está no chão ou já desceu o suficiente
	_flap_timer -= delta
	if _flap_timer <= 0.0 and (is_on_floor() or height <= MAX_FLY_HEIGHT * REFLAP_HEIGHT):
		_vy = FLAP_IMPULSE
		_flap_timer = FLAP_INTERVAL

	velocity.y = _vy

func _update_ground_ref() -> void:
	if is_on_floor():
		_ground_y = global_position.y
		_has_ground_ref = true
