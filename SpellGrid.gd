extends Node2D


var current_casting: Array[Globals.MagicType] = []

@onready var spell_points: Array[Node] = [
	$FirePoint,
	$AirPoint,
	$WaterPoint,
]

func complete_spell() -> Array[Globals.MagicType]:
	# Reset the points
	for spell_point in spell_points:
		spell_point.reset()
	
	# Return the cast spell and clear the casting grid
	var spell_casting = current_casting
	current_casting = []
	return spell_casting


func _on_point_activated(magic_type: Globals.MagicType):
	current_casting.append(magic_type)
