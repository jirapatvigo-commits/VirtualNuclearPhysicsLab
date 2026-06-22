extends MeshInstance3D

var dragging := false
var selected := false

func deselect():
	selected = false
	dragging = false

func _input(event):
	var lab = get_tree().current_scene

	if lab == null:
		return

	if not lab.design_mode:
		dragging = false
		selected = false
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:

			get_tree().call_group(
				"draggable_objects",
				"deselect"
			)

			selected = true

			print(name, " selected")

		if selected:

			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = event.pressed

	elif event is InputEventMouseMotion:

		if dragging:

			position.x += event.relative.x * 0.01
			position.z += event.relative.y * 0.01
