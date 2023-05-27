extends Area3D

signal bolt_of_fire_collision(bolt)

var velocity: Vector3
var caster: Node3D

func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(_body):
	emit_signal("bolt_of_fire_collision", self)

func _on_area_entered(_area):
	emit_signal("bolt_of_fire_collision", self)

func _on_timer_timeout():
	queue_free()
