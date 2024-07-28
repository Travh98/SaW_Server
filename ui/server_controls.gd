class_name ServerControls
extends Control

## Controls for the Server

signal spawn_red_knight()
signal spawn_blue_knight()

@onready var seed_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/SeedLineEdit
@onready var level_gen_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelGenButton
@onready var spawn_red_knight_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SpawnRedKnight
@onready var spawn_blue_knight_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SpawnBlueKnight

func _ready():
	level_gen_button.pressed.connect(on_level_gen)
	spawn_red_knight_button.pressed.connect(on_spawn_red_knight)
	spawn_blue_knight_button.pressed.connect(on_spawn_blue_knight)
	
	spawn_red_knight.connect(Server.spawn_red_knight)
	spawn_blue_knight.connect(Server.spawn_blue_knight)


func on_level_gen():
	var seed_str: String = seed_line_edit.text
	if seed_str.is_empty():
		seed_str = "balloon"
	Server.generate_level(seed_str)


func on_spawn_red_knight():
	spawn_red_knight.emit()


func on_spawn_blue_knight():
	spawn_blue_knight.emit()
