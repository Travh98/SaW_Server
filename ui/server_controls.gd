extends Control

## Controls for the Server

@onready var seed_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/SeedLineEdit
@onready var level_gen_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelGenButton

func _ready():
	level_gen_button.pressed.connect(on_level_gen)


func on_level_gen():
	var seed_str: String = seed_line_edit.text
	if seed_str.is_empty():
		seed_str = "balloon"
	Server.generate_level(seed_str)
