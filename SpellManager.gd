extends Node

@onready var arena: Node3D = $"../HiddenTown"

var _spells: Dictionary = {
	"BTSLE": respawn,
	"BELST": respawn,
	"LEBTS": respawn,
	"LSTBE": respawn,
	"TSLEB": respawn,
	"TBELS": respawn,
	"EBTSL": respawn,
	"ELSTB": respawn,
	"SLEBT": respawn,
	"STBEL": respawn,
}

func register_caster(caster: Node) -> void:
	if caster.has_signal("spell_cast"):
		caster.connect("spell_cast", _spell_cast)

func _spell_cast(caster: Node3D, spell_key: String, casting_travel: int, target) -> void:
	
	if not spell_key in _spells:
		print("The Node " + str(caster) + " attempted to cast " + spell_key + " at " + str(target) + " with travel " + str(casting_travel))
		return
	
	var spell_function: Callable = _spells[spell_key]
	spell_function.call(caster, casting_travel)

func respawn(caster: Node3D, _casting_travel: int) -> void:
	if not caster.has_method("respawn"):
		return
	
	var next_spawn: Vector3 = Vector3.ZERO
	
	if arena.has_method("get_next_spawn"):
		print("Getting next spawn from arena")
		next_spawn = arena.get_next_spawn()
	
	if caster.get_multiplayer_authority() == 1:
		caster.respawn(next_spawn)
	else:
		caster.respawn.rpc_id(caster.get_multiplayer_authority(), next_spawn)
		print(str(caster) + " cast respawn")

