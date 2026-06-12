class_name FireballProjectile
extends Projectile

## Bola de fogo gigante (habilidade do Clérigo). Maior e vermelha.

func _ready() -> void:
	super._ready()
	modulate = Color(1.0, 0.2, 0.0, 1.0)
	scale = Vector2(2.5, 2.5)
	speed = 380.0
