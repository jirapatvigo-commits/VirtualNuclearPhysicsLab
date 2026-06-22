extends Node3D

# ===== UI Buttons =====
@onready var emit_button = $UI/ControlPanel/VBoxContainer/EmitButton
@onready var increase_button = $UI/ControlPanel/VBoxContainer/IncreaseButton
@onready var decrease_button = $UI/ControlPanel/VBoxContainer/DecreaseButton
@onready var reset_graph_button = $UI/ControlPanel/VBoxContainer/ResetGraphButton
@onready var design_button = $UI/ControlPanel/VBoxContainer/DesignModeButton
@onready var back_button = $UI/ControlPanel/VBoxContainer/BackButton
@onready var absorber1_option = $UI/ControlPanel/VBoxContainer/Absorber1Option
@onready var absorber2_option = $UI/ControlPanel/VBoxContainer/Absorber2Option
@onready var detector_mode_option = $UI/ControlPanel/VBoxContainer/DetectorModeOption

# ===== UI Controls =====
@onready var material_option = $UI/ControlPanel/VBoxContainer/MaterialOption
@onready var radiation_option = $UI/ControlPanel/VBoxContainer/RadiationOption
@onready var save_layout_button = $UI/ControlPanel/VBoxContainer/SaveLayoutButton
@onready var load_layout_button = $UI/ControlPanel/VBoxContainer/LoadLayoutButton

# ===== UI Labels =====
@onready var thickness_label = $UI/ControlPanel/VBoxContainer/ThicknessLabel
@onready var result_label = $UI/ControlPanel/VBoxContainer/ResultLabel

# ===== Experiment Objects =====
@onready var source = $Source
@onready var absorber = $Absorber
@onready var absorber2 = $Absorber2
@onready var detector = $Detector
@onready var camera = $Camera3D
@onready var beam_line = $BeamLine

# ===== Systems =====
@onready var graph = $BetaGraph
@onready var notebook = $NotebookPanel
@onready var detector_timer = $DetectorTimer

var selected_object = null
var drag_plane_y := 0.0
var thickness := 1
var initial_intensity := 1000
var mu := 0.3
var radiation_type := "Beta"
var absorber1_material := "Plastic"
var absorber2_material := "Lead"
var detector_mode := "Count"

var material_mu = {
	"Plastic": 0.15,
	"Aluminum": 0.30,
	"Lead": 0.60
}
var absorber1_mu := 0.15
var absorber2_mu := 0.60

var beta_scene = preload("res://scenes/BetaParticle.tscn")

var rng = RandomNumberGenerator.new()

var design_mode := false
var camera_angle := 0.0
var camera_distance := 8.0

func _ready():
	emit_button.pressed.connect(_on_emit_pressed)
	increase_button.pressed.connect(_on_increase_pressed)
	decrease_button.pressed.connect(_on_decrease_pressed)

	design_button.pressed.connect(
		_on_design_mode_pressed
	)

	material_option.item_selected.connect(
		_on_material_selected
	)

	back_button.pressed.connect(_on_back_pressed)

	reset_graph_button.pressed.connect(
		_on_reset_graph_pressed
	)

	detector_timer.timeout.connect(
		_on_detector_timeout
	)
	
	save_layout_button.pressed.connect(
		_on_save_layout_pressed
	)

	load_layout_button.pressed.connect(
		_on_load_layout_pressed
	)
	
	radiation_option.item_selected.connect(
		_on_radiation_selected
	)
	
	absorber1_option.item_selected.connect(
		_on_absorber1_selected
	)

	absorber2_option.item_selected.connect(
		_on_absorber2_selected
	)
	absorber1_option.select(1)
	absorber2_option.select(3)

	absorber1_material = "Plastic"
	absorber2_material = "Lead"
	
	detector_mode_option.item_selected.connect(
		_on_detector_mode_selected
	)
	
	material_option.select(0)
	radiation_option.select(0)
	detector_mode_option.select(0)
	
	update_ui()


func update_ui():

	if material_option.selected < 0:
		return

	var material = material_option.get_item_text(
		material_option.selected
	)

	thickness_label.text = (
		"Material: %s\nThickness: %d mm"
		% [material, thickness]
	)


func _on_increase_pressed():
	thickness += 1
	update_ui()


func _on_decrease_pressed():
	if thickness > 0:
		thickness -= 1

	update_ui()

func _on_emit_pressed():

	# ระยะ Source -> Detector
	var distance = source.position.distance_to(
		detector.position
	)

	var distance_factor = 1.0 / (1.0 + distance * 0.1)

	# สูตรดูดกลืนพื้นฐาน
	var ideal_detected = (
		initial_intensity
		* exp(-mu * thickness)
		* distance_factor
	)
	
	if radiation_type == "Alpha":
		ideal_detected *= 0.2

	elif radiation_type == "Beta":
		pass

	elif radiation_type == "Gamma":
		ideal_detected *= 1.5
	
	var absorber_bonus = 1.0

	# ==========================
	# Absorber 1
	# ==========================

	var source_to_detector = detector.global_position - source.global_position
	var detector_direction = source_to_detector.normalized()

	var source_to_absorber = absorber.global_position - source.global_position

	var projection = source_to_absorber.dot(detector_direction)

	var closest_point = source.global_position + detector_direction * projection

	var offset = absorber.global_position.distance_to(closest_point)

	if offset < 1.0:
		absorber_bonus *= get_absorption_factor(
			absorber1_material,
			radiation_type
		)

	# ==========================
	# Absorber 2
	# ==========================

	var source_to_absorber2 = absorber2.global_position - source.global_position

	var projection2 = source_to_absorber2.dot(
			detector_direction
		)

	var closest_point2 = source.global_position + detector_direction * projection2

	var offset2 = absorber2.global_position.distance_to(
			closest_point2
		)

	if offset2 < 1.0:
		absorber_bonus *= get_absorption_factor(
			absorber2_material,
			radiation_type
		)

	# ==========================

	ideal_detected *= absorber_bonus

	# Noise
	var noise = rng.randi_range(-15, 15)

	var detected = round(
		ideal_detected + noise
	)

	detected = clamp(
		detected,
		0,
		initial_intensity
	)

	var absorbed = initial_intensity - detected

	var detector_text = ""

	if detector_mode == "Count":

		detector_text = (
			"Detected : %d counts"
			% detected
		)

	elif detector_mode == "Dose":

		var dose = detected * 0.01

		detector_text = (
			"Dose : %.2f mSv"
			% dose
		)

	elif detector_mode == "Energy":

		var energy = detected * 2.5

		detector_text = (
			"Energy : %.1f keV"
			% energy
		)

	result_label.text = (
		"Emitted : %d\n%s\nAbsorbed : %d"
		% [
			initial_intensity,
			detector_text,
			absorbed
		]
	)
	
	emit_visual_particles(detected)

	graph.add_data(thickness, detected)

	var material = material_option.get_item_text(
		material_option.selected
	)

	var trial_number = notebook.records.size() + 1

	notebook.add_record(
		trial_number,
		material,
		thickness,
		detected
	)

	if detected > 0:
		flash_detector()

func emit_visual_particles(detected_count):

	var direction = (
		detector.global_position
		- source.global_position
	).normalized()

	for i in range(30):

		var particle = beta_scene.instantiate()

		particle.position = source.global_position

		var pass_probability = (
			float(detected_count)
			/ initial_intensity
		)

		if rng.randf() < pass_probability:

			particle.velocity = direction * 4

		else:

			particle.velocity = direction * 2

		add_child(particle)


func _on_reset_graph_pressed():
	graph.clear_data()


func flash_detector():
	print("FLASH DETECTOR CALLED")

	if detector.material_override:
		print("Material found")
		detector.material_override.albedo_color = Color.GREEN
	else:
		print("NO MATERIAL!")

	detector_timer.start()


func _on_detector_timeout():
	print("TIMEOUT")

	if detector.material_override:
		detector.material_override.albedo_color = Color.RED


func _on_back_pressed():
	get_tree().change_scene_to_file(
		"res://scenes/MainMenu.tscn"
	)
	
func _on_material_selected(index):
	var material = material_option.get_item_text(index)

	mu = material_mu[material]

	update_ui()

	print("Material:", material)
	print("Mu:", mu)
	
func _on_design_mode_pressed():
	design_mode = !design_mode

	if design_mode:
		design_button.text = "Exit Design Mode"

		result_label.text = (
			"Design Mode : ON\n"
			+ "Drag equipment."
		)

		print("Design Mode ON")

	else:
		design_button.text = "Design Experiment"

		result_label.text = "Design Mode : OFF"

		print("Design Mode OFF")
		
func _input(event):

	# หมุนกล้อง
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(
			MOUSE_BUTTON_RIGHT
		):
			camera_angle += event.relative.x * 0.01

	# ระบบ Design Mode เดิม
	if not design_mode:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				var mouse_pos = get_viewport().get_mouse_position()

				var from = camera.project_ray_origin(mouse_pos)
				var to = from + camera.project_ray_normal(mouse_pos) * 1000

				var query = PhysicsRayQueryParameters3D.create(from, to)

				var result = get_world_3d().direct_space_state.intersect_ray(query)

				if result:
					selected_object = result.collider

					drag_plane_y = (
						selected_object.get_parent()
						.global_position.y
					)

			else:
				selected_object = null
				
func _process(delta):

	# หมุนกล้องรอบห้องทดลอง
	camera.position = Vector3(
		sin(camera_angle) * camera_distance,
		3.0,
		cos(camera_angle) * camera_distance
	)

	camera.look_at(
		Vector3.ZERO,
		Vector3.UP
	)
	
	update_beam_line()
	
	# ระบบลากอุปกรณ์เดิม
	if not design_mode:
		return

	if selected_object == null:
		return

	if Input.is_mouse_button_pressed(
		MOUSE_BUTTON_LEFT
	):

		var mouse_pos = get_viewport().get_mouse_position()

		var ray_origin = camera.project_ray_origin(
			mouse_pos
		)

		var ray_dir = camera.project_ray_normal(
			mouse_pos
		)

		if abs(ray_dir.y) < 0.001:
			return

		var t = (
			drag_plane_y - ray_origin.y
		) / ray_dir.y

		var hit_pos = (
			ray_origin
			+ ray_dir * t
		)

		selected_object.get_parent().global_position.x = (
			hit_pos.x
		)

		selected_object.get_parent().global_position.z = (
			hit_pos.z
		)

func _on_save_layout_pressed():

	var data = {
		"source": {
			"x": source.position.x,
			"y": source.position.y,
			"z": source.position.z
		},
		"absorber": {
			"x": absorber.position.x,
			"y": absorber.position.y,
			"z": absorber.position.z
		},
		"absorber2": {
			"x": absorber2.position.x,
			"y": absorber2.position.y,
			"z": absorber2.position.z
		},
		"detector": {
			"x": detector.position.x,
			"y": detector.position.y,
			"z": detector.position.z
		}
	}

	var file = FileAccess.open(
		"user://layout.json",
		FileAccess.WRITE
	)

	file.store_string(
		JSON.stringify(data)
	)

	file.close()

	print("Layout Saved")
	
func _on_load_layout_pressed():

	if not FileAccess.file_exists(
		"user://layout.json"
	):
		print("No layout file.")
		return

	var file = FileAccess.open(
		"user://layout.json",
		FileAccess.READ
	)

	var text = file.get_as_text()

	file.close()

	var json = JSON.new()

	var error = json.parse(text)

	if error != OK:
		print("JSON Error")
		return

	var data = json.data

	source.position = Vector3(
		data["source"]["x"],
		data["source"]["y"],
		data["source"]["z"]
	)

	absorber.position = Vector3(
		data["absorber"]["x"],
		data["absorber"]["y"],
		data["absorber"]["z"]
	)
	
	absorber2.position = Vector3(
		data["absorber2"]["x"],
		data["absorber2"]["y"],
		data["absorber2"]["z"]
	)

	detector.position = Vector3(
		data["detector"]["x"],
		data["detector"]["y"],
		data["detector"]["z"]
	)

	print("Layout Loaded")

func update_beam_line():

	var start_pos = source.global_position
	var end_pos = detector.global_position

	var center = (
		start_pos + end_pos
	) / 2.0

	beam_line.global_position = center

	var distance = start_pos.distance_to(
		end_pos
	)

	beam_line.scale.y = distance / 2.0

	beam_line.look_at(
		end_pos,
		Vector3.UP
	)

	beam_line.rotate_object_local(
		Vector3.RIGHT,
		deg_to_rad(90)
	)
	
func _on_radiation_selected(index):

	radiation_type = radiation_option.get_item_text(index)

	print("Radiation:", radiation_type)

func get_absorption_factor(material_name, radiation):

	match radiation:

		"Alpha":
			match material_name:
				"Paper":
					return 0.05
				"Plastic":
					return 0.10
				"Aluminum":
					return 0.01
				"Lead":
					return 0.001

		"Beta":
			match material_name:
				"Paper":
					return 0.90
				"Plastic":
					return 0.70
				"Aluminum":
					return 0.40
				"Lead":
					return 0.15

		"Gamma":
			match material_name:
				"Paper":
					return 0.98
				"Plastic":
					return 0.95
				"Aluminum":
					return 0.80
				"Lead":
					return 0.30

	return 1.0
	
func _on_absorber1_selected(index):

	absorber1_material = absorber1_option.get_item_text(index)

	print(
		"Absorber1 Material:",
		absorber1_material
	)
	
func _on_absorber2_selected(index):

	absorber2_material = absorber2_option.get_item_text(index)

	print(
		"Absorber2 Material:",
		absorber2_material
	)
	
func _on_detector_mode_selected(index):

	detector_mode = detector_mode_option.get_item_text(index)
