extends Node2D


var current_casting: Array[Enums.MagicType] = []

@onready var spell_points: Array[Node] = [
	$Inner/FirePoint,
	$Inner/AirPoint,
	$Inner/WaterPoint,
	$Outer/EarthPoint,
	$Outer/SpiritPoint,
	$Outer/BloodPoint,
	$Outer/LightningPoint,
	$Outer/ThrustPoint,
]

func complete_spell() -> Array[Enums.MagicType]:
	# Reset the points
	for spell_point in spell_points:
		spell_point.reset()
	
	# Return the cast spell and clear the casting grid
	var spell_casting = current_casting
	current_casting = []
	return spell_casting


func _on_point_activated(magic_type: Enums.MagicType):
	current_casting.append(magic_type)
