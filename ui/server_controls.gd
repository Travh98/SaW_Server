class_name ServerControls
extends Control

## Controls for the Server

signal spawn_red_knight()
signal spawn_blue_knight()

@onready var server_data_loader = $ServerDataLoader

@onready var seed_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/SeedLineEdit
@onready var level_gen_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelGenButton
@onready var spawn_red_knight_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SpawnRedKnight
@onready var spawn_blue_knight_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SpawnBlueKnight
@onready var map_selections: Container = $MarginContainer/HBoxContainer/VBoxContainer2/MapSelections
@onready var mode_selections: Container = $MarginContainer/HBoxContainer/VBoxContainer2/ModeSelections
@onready var apply_button: Button = $MarginContainer/HBoxContainer/VBoxContainer2/ApplyButton

func _ready():
	server_data_loader.maps_loaded.connect(on_maps_loaded)
	
	level_gen_button.pressed.connect(on_level_gen)
	spawn_red_knight_button.pressed.connect(on_spawn_red_knight)
	spawn_blue_knight_button.pressed.connect(on_spawn_blue_knight)
	
	spawn_red_knight.connect(Server.spawn_red_knight)
	spawn_blue_knight.connect(Server.spawn_blue_knight)
	
	apply_button.pressed.connect(on_apply_server_settings)


func on_level_gen():
	var seed_str: String = seed_line_edit.text
	if seed_str.is_empty():
		seed_str = "balloon"
	Server.level_generator.start_generation(seed_str)


func on_spawn_red_knight():
	spawn_red_knight.emit()


func on_spawn_blue_knight():
	spawn_blue_knight.emit()


func on_maps_loaded(maps_str_array: Array):
	var maps_button_group: ButtonGroup = ButtonGroup.new()
	for m in maps_str_array:
		var map_button: CheckBox = CheckBox.new()
		map_button.text = str(m)
		map_button.button_group = maps_button_group
		map_selections.add_child(map_button)
		


func on_apply_server_settings():
	var mode_str: String
	var map_str: String
	for b in mode_selections.get_children():
		if b is Button:
			if b.button_pressed == true:
				mode_str = b.text
	for b in map_selections.get_children():
		if b is CheckBox:
			if b.button_pressed == true:
				map_str = b.text
	print("ServerUI: ", mode_str, " on map: ", map_str)
	Server.server_changed_map(map_str)
	Server.server_changed_mode(mode_str)
