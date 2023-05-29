extends Node

@onready var arena: Node3D = $"../HiddenTown"
@onready var BoltOfFire: PackedScene = preload("res://spells/BoltOfFire.tscn")
@onready var BoltOfFireExplosion: PackedScene = preload("res://spells/BoltOfFireExplosion.tscn")

const bolt_of_fire_velocity: float = 10.0

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
	"FT": bolt_of_fire,
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

func bolt_of_fire(caster: Node3D, _casting_travel: int) -> void:
	var bolt: Area3D = BoltOfFire.instantiate()
	var pos: Vector3 = caster.global_position + Vector3.FORWARD
	var direction: Vector3 = Vector3.BACK
	
	if caster.has_method("get_projectile_transform"):
		var transform: Transform3D = caster.get_projectile_transform()
		pos = transform.origin
		direction = -transform.basis.z
			
	owner.add_child(bolt, true)
	bolt.connect("bolt_of_fire_collision", bolt_of_fire_collision)
	bolt.global_position = pos
	print("direction: " + str(direction))
	bolt.velocity = direction * bolt_of_fire_velocity
	bolt.look_at(bolt.global_position + direction)
	bolt.caster = caster

func bolt_of_fire_collision(bolt: Area3D) -> void:
	bolt.disconnect("bolt_of_fire_collision", bolt_of_fire_collision)
	var explosion: Area3D = BoltOfFireExplosion.instantiate()
	owner.add_child(explosion, true)
	explosion.global_position = bolt.global_position
	explosion.caster = bolt.caster
	
	bolt.queue_free()
