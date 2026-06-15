extends Node3D

@onready var decay_button = $UI/Control/VBoxContainer/DecayButton
@onready var beta_button = $UI/Control/VBoxContainer/BetaButton
@onready var explorer_button = $UI/Control/VBoxContainer/ExplorerButton
@onready var exit_button = $UI/Control/VBoxContainer/ExitButton


func _ready():
	decay_button.pressed.connect(_on_decay_pressed)
	beta_button.pressed.connect(_on_beta_pressed)
	explorer_button.pressed.connect(_on_explorer_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_decay_pressed():
	get_tree().change_scene_to_file(
		"res://scenes/DecayStatistics.tscn"
	)


func _on_beta_pressed():
	get_tree().change_scene_to_file(
		"res://scenes/BetaAbsorption.tscn"
	)


func _on_explorer_pressed():
	get_tree().change_scene_to_file(
		"res://scenes/RadiationExplorer.tscn"
	)


func _on_exit_pressed():
	get_tree().quit()
