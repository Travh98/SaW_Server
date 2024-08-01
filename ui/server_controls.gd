class_name ServerControls
extends Control

## Controls for the Server

signal start_level_gen(seed: String)
signal spawn_red_knight()
signal spawn_blue_knight()
signal set_freeze_time_msec(freeze_time_msec: int)
signal set_freeze_time_enabled(enable: bool)
signal print_player_data()

@onready var server_data_loader = $ServerDataLoader

@onready var seed_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/SeedLineEdit
@onready var level_gen_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelGenButton
@onready var spawn_red_knight_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SpawnRedKnight
@onready var spawn_blue_knight_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SpawnBlueKnight
@onready var map_selections: Container = $MarginContainer/HBoxContainer/VBoxContainer2/MapSelections
@onready var mode_selections: Container = $MarginContainer/HBoxContainer/VBoxContainer2/ModeSelections
@onready var apply_button: Button = $MarginContainer/HBoxContainer/VBoxContainer2/ApplyButton

@onready var freeze_time_spin_box: SpinBox = $MarginContainer/HBoxContainer/VBoxContainer/GridContainer/FreezeTimeSpinBox
@onready var apply_freeze_time: Button = $MarginContainer/HBoxContainer/VBoxContainer/GridContainer/ApplyFreezeTime
@onready var toggle_freeze_time_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/GridContainer/ToggleFreezeTimeButton
@onready var print_player_data_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/PrintPlayerDataButton


func _ready():
	server_data_loader.maps_loaded.connect(on_maps_loaded)
	
	level_gen_button.pressed.connect(on_level_gen)
	spawn_red_knight_button.pressed.connect(on_spawn_red_knight)
	spawn_blue_knight_button.pressed.connect(on_spawn_blue_knight)
	
	apply_button.pressed.connect(on_apply_server_settings)
	
	apply_freeze_time.pressed.connect(on_freeze_time_apply)
	toggle_freeze_time_button.toggled.connect(on_freeze_time_toggled)
	
	print_player_data_button.pressed.connect(func(): self.print_player_data.emit())
	
	populate_modes.call_deferred()


func on_level_gen():
	var seed_str: String = seed_line_edit.text
	if seed_str.is_empty():
		seed_str = "balloon"
	start_level_gen.emit(seed_str)


func on_spawn_red_knight():
	spawn_red_knight.emit()


func on_spawn_blue_knight():
	spawn_blue_knight.emit()


func populate_modes():
	var mode_button_group: ButtonGroup = ButtonGroup.new()
	for m in Server.state_mgr.ServerMode.keys():
		var mode_button: = CheckBox.new()
		mode_button.text = m
		mode_button.button_group = mode_button_group
		mode_selections.add_child(mode_button)


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
	
	Server.map_mgr.server_changed_map(map_str)
	Server.state_mgr.server_changed_mode(mode_str)


func on_freeze_time_apply():
	set_freeze_time_msec.emit(freeze_time_spin_box.value)


func on_freeze_time_toggled(enable: bool):
	set_freeze_time_enabled.emit(enable)
