extends Area3D


var velocity : Vector3

func _process(delta: float) -> void:
	position += velocity * delta
	look_at(position + velocity)

func _on_body_entered(_body):
	queue_free()

func _on_area_entered(_area):
	queue_free()
