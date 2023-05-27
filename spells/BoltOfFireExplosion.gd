extends Area3D

@export var damage: float = 10.0

var caster: Node3D

@onready var particles_1: GPUParticles3D = $GPUParticles3D
@onready var particles_2: GPUParticles3D = $GPUParticles3D2

func _ready() -> void:
	particles_1.restart()
	particles_2.restart()
