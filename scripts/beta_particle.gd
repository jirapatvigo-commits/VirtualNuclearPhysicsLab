extends Node3D

var velocity := Vector3.ZERO


func _process(delta):
	position += velocity * delta

	if position.distance_to(Vector3.ZERO) > 20:
		queue_free()
