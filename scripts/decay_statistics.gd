extends Control

@onready var start_button = $MainLayout/LeftPanel/StartButton
@onready var result_box = $MainLayout/LeftPanel/ResultBox
@onready var mean_label = $MainLayout/LeftPanel/MeanLabel
@onready var error_label = $MainLayout/LeftPanel/ErrorLabel
@onready var back_button = $MainLayout/LeftPanel/BackButton

@onready var histogram = $MainLayout/RightPanel/Histogram

var rng = RandomNumberGenerator.new()
var experiment_counts = []

func _ready():
	start_button.pressed.connect(_on_start_pressed)

	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_start_pressed():
	result_box.clear()

	experiment_counts.clear()

	for i in range(36):
		var count = poisson_random(120)	

		experiment_counts.append(count)

		result_box.append_text(
			"Count #%d : %d\n" % [i + 1, count]
		)

	calculate_statistics(experiment_counts)
	histogram.set_data(experiment_counts)

func calculate_statistics(counts):
	var total = 0

	for c in counts:
		total += c

	var mean = float(total) / counts.size()

	var standard_error = sqrt(mean) / sqrt(counts.size())

	mean_label.text = "Mean Count: %.2f" % mean
	error_label.text = "Standard Error: %.2f" % standard_error
	
func poisson_random(lambda_value):
	var l = exp(-lambda_value)

	var k = 0
	var p = 1.0

	while p > l:
		k += 1
		p *= rng.randf()

	return k - 1
	
func _on_back_pressed():
	get_tree().change_scene_to_file(
		"res://scenes/MainMenu.tscn"
	)
