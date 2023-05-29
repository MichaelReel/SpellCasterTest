extends Control

@export var game_manager : GameManager

var last_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	hide()
	game_manager.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)

func _on_game_manager_toggle_game_paused(is_paused: bool) -> void:
	if is_paused:
		last_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		show()
	else:
		Input.mouse_mode = last_mouse_mode
		hide()

func _on_resume_button_pressed():
	game_manager.game_paused = false

func _on_quit_button_pressed():
	get_tree().quit()
