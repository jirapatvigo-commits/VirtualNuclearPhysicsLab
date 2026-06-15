extends Control

@onready var radiation_option = $VBoxContainer/RadiationOption
@onready var material_option = $VBoxContainer/MaterialOption

@onready var test_button = $VBoxContainer/TestButton
@onready var back_button = $VBoxContainer/BackButton

@onready var result_label = $VBoxContainer/ResultLabel


func _ready():
	test_button.pressed.connect(_on_test_pressed)
	back_button.pressed.connect(_on_back_pressed)


func _on_test_pressed():

	var radiation = radiation_option.get_item_text(
		radiation_option.selected
	)

	var material = material_option.get_item_text(
		material_option.selected
	)

	result_label.text = (
		"Result : "
		+ get_result(radiation, material)
	)


func get_result(radiation, material):

	if radiation == "Alpha":
		return "Blocked"

	if radiation == "Beta":

		if material == "Paper":
			return "Pass"

		if material == "Aluminium":
			return "Partial"

		return "Blocked"

	if radiation == "Gamma":

		if material == "Paper":
			return "Pass"

		if material == "Aluminium":
			return "Pass"

		return "Partial"

	return ""


func _on_back_pressed():
	get_tree().change_scene_to_file(
		"res://scenes/MainMenu.tscn"
	)
