extends Node

func register_caster(caster: Node) -> void:
	
	if caster.has_signal("spell_cast"):
		caster.connect("spell_cast", _spell_cast)

func _spell_cast(caster: Node3D, spell_key: String, casting_travel: int) -> void:
	
	print("The Node " + str(caster) + " is casting " + spell_key + " with travel " + str(casting_travel))
