extends Node

## Loads map data from a file

signal maps_loaded(Array)

var map_str_array: Array

func _ready():
	map_str_array.append("good_and_nice_castle")
	map_str_array.append("flake")
	map_str_array.append("bonnet_shores")
	map_str_array.append("sa_w_level") # PVE test
	
	#await get_tree().create_timer(1).timeout
	send_loaded_map_names.call_deferred()


func send_loaded_map_names():
	maps_loaded.emit(map_str_array)
