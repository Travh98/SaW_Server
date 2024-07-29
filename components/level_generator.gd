class_name LevelGenerator
extends Node

## Generates the level

signal level_tiles_generated(String)

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var serialized_tile_string: String

var num_steps: int = 0
var max_steps: int = 200
var steps_since_turn: int = 0
var first_hall_length: int = 6

var current_pos: Vector2 = Vector2.ZERO
var current_dir: Vector2 = Vector2.UP # Negative Y is up
var last_spot: Vector2 = Vector2.ZERO
var step_history: Array[Vector2]
var borders: Rect2 = Rect2(-20, -39, 40, 40)


func _ready():
	level_tiles_generated.connect(on_level_tiles_generated)


# Sends tile data to all Clients
func on_level_tiles_generated(tile_array_str: String):
	print("Sending ", tile_array_str.length(), " characters of tiles to clients")
	Server.generated_level_tiles.rpc(tile_array_str)


# Sends tile data to a specific client (for late joiners)
func send_tile_data(peer_id: int):
	if !serialized_tile_string.is_empty():
		Server.generated_level_tiles.rpc_id(peer_id, serialized_tile_string)


func start_generation(seed_str: String):
	seed(seed_str.hash()) # Hash the seed to a number
	
	# This array is what we will rpc to clients
	var pos_array: Array = generate_castle()
	var serialized_array: String = serialize_vector2_array(pos_array)
	#print("Serialized generation: ", serialized_array)
	serialized_tile_string = serialized_array
	
	# Send tile array to Clients
	level_tiles_generated.emit(serialized_array)


func generate_castle() -> Array[Vector2]:
	step_history.append(current_pos)
	
	for step_index in max_steps:
		if randf() <= 0.25 or steps_since_turn >= 4:
			if num_steps > first_hall_length:
				change_direction()
		
		if step():
			# Add new pos to step history
			step_history.append(current_pos)
	return step_history


func step() -> bool:
	var target_pos = current_pos + current_dir
	if borders.has_point(target_pos):
		steps_since_turn += 1
		num_steps += 1
		current_pos = target_pos
		return true
	else:
		return false

func change_direction():
	steps_since_turn = 0
	var possible_dirs = DIRECTIONS.duplicate()
	possible_dirs.erase(current_dir)
	possible_dirs.shuffle()
	current_dir = possible_dirs.pop_front()
	# Check each new direction until we find one that isnt taken
	while not borders.has_point(current_pos + current_dir):
		current_dir = possible_dirs.pop_front()
		if possible_dirs.is_empty():
			return


func serialize_vector2_array(pos_array) -> String:
	var serialized_array: String = ""
	for pos in pos_array:
		serialized_array += vec2_to_str(pos) + ","
	return serialized_array


func vec2_to_str(pos: Vector2) -> String:
	return "[" + str(int(pos.x)) + " " + str(int(pos.y)) + "]"
