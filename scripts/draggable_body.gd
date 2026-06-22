extends StaticBody3D

var dragging := false

func _input_event(_camera, event, _position, _normal, _shape_idx):

	print("CLICKED ", get_parent().name)

	var lab = get_tree().current_scene

	if lab == null:
		return

	if not lab.design_mode:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

func _process(_delta):
	if not dragging:
		return

	var motion = Input.get_last_mouse_velocity()

	position.x += motion.x * 0.001
	position.z += motion.y * 0.001
