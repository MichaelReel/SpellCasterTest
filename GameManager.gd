class_name GameManager
extends Node

signal toggle_game_paused(is_paused: bool)

var game_paused: bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		emit_signal("toggle_game_paused", game_paused)
		get_tree().paused = game_paused 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		game_paused = not game_paused
