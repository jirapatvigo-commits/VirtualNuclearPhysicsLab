extends Node3D

@onready var reset_graph_button = $UI/ControlPanel/VBoxContainer/ResetGraphButton
@onready var emit_button = $UI/ControlPanel/VBoxContainer/EmitButton
@onready var increase_button = $UI/ControlPanel/VBoxContainer/IncreaseButton
@onready var decrease_button = $UI/ControlPanel/VBoxContainer/DecreaseButton

@onready var thickness_label = $UI/ControlPanel/VBoxContainer/ThicknessLabel
@onready var result_label = $UI/ControlPanel/VBoxContainer/ResultLabel

@onready var graph = $BetaGraph

@onready var detector = $Detector
@onready var detector_timer = $DetectorTimer
@onready var back_button = $UI/ControlPanel/VBoxContainer/BackButton


var thickness := 1
var initial_intensity := 1000
var mu := 0.3

var beta_scene = preload("res://scenes/BetaParticle.tscn")

var rng = RandomNumberGenerator.new()


func _ready():
	emit_button.pressed.connect(_on_emit_pressed)
	increase_button.pressed.connect(_on_increase_pressed)
	decrease_button.pressed.connect(_on_decrease_pressed)
	back_button.pressed.connect(_on_back_pressed)

	reset_graph_button.pressed.connect(_on_reset_graph_pressed)

	detector_timer.timeout.connect(_on_detector_timeout)

	update_ui()


func update_ui():
	thickness_label.text = "Thickness : %d mm" % thickness


func _on_increase_pressed():
	thickness += 1
	update_ui()


func _on_decrease_pressed():
	if thickness > 0:
		thickness -= 1

	update_ui()


func _on_emit_pressed():
	var detected = round(
		initial_intensity * exp(-mu * thickness)
	)

	var absorbed = initial_intensity - detected

	result_label.text = (
		"Emitted : %d\nDetected : %d\nAbsorbed : %d"
		% [initial_intensity, detected, absorbed]
	)

	emit_visual_particles(detected)

	graph.add_data(thickness, detected)

	if detected > 0:
		flash_detector()


func emit_visual_particles(detected_count):
	for i in range(30):

		var particle = beta_scene.instantiate()

		particle.position = $Source.position

		var pass_probability = (
			float(detected_count)
			/ initial_intensity
		)

		if rng.randf() < pass_probability:

			particle.velocity = Vector3(
				rng.randf_range(-0.1, 0.1),
				0,
				-4
			)

		else:

			particle.velocity = Vector3(
				rng.randf_range(-0.1, 0.1),
				0,
				-2
			)

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
