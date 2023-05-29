extends Node3D

@onready var spawn_list: Array[Vector3] = [
	$Spawns/BridgeA.position,
	$Spawns/MidCourt.position,
	$Spawns/BridgeCA.position,
	$Spawns/BridgeCB.position,
	$Spawns/LowerCourt.position,
	$Spawns/UpperCourt.position,
]

func get_next_spawn() -> Vector3:
	return spawn_list[randi() % len(spawn_list)]
