extends Control

## Compartilhado por GameOver e Victory.

@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)

func _on_menu_pressed() -> void:
	GameManager.go_to_main_menu()
