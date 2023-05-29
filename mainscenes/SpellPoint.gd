extends Node2D

signal point_activated(magic_type: Globals.MagicType)

@export var color: Color = Color.CADET_BLUE
@export var type: Globals.MagicType = Globals.MagicType.AIR

@onready var activated_sprite: Sprite2D = $ActivatedSprite

func _ready():
	activated_sprite.modulate = color

func reset():
	activated_sprite.visible = false

func activate():
	if activated_sprite.visible:
		return
	
	emit_signal("point_activated", type)
	activated_sprite.visible = true

func _on_area_2d_area_entered(_area):
	activate()
