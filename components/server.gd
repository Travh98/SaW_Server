extends Node

## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s

signal ping_reported(peer_id: int, ping: float)

@onready var level_generator: LevelGenerator = $LevelGenerator

var network: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port: int = 25026
var max_players: int = 64
var connected_peer_ids = []
var game_tree: GameTree


func _ready():
	if !search_for_game_tree():
		return
		
	level_generator.level_tiles_generated.connect(on_level_tiles_generated)
	start_server()


func start_server():
	network.create_server(port, max_players)
	multiplayer.multiplayer_peer = network
	print("Server started on port: ", str(port))
	
	network.peer_connected.connect(on_peer_connected)
	network.peer_disconnected.connect(on_peer_disconnected)


func on_peer_connected(new_peer_id: int):
	print("User ", str(new_peer_id), " connected.")
	# Spawn existing players for the new client
	add_previously_connected_player_characters.rpc_id(new_peer_id, connected_peer_ids)
	# Spawn a new player for the new client
	add_newly_connected_player_character.rpc(new_peer_id)
	# Spawn a corresponding player node for the server to keep track
	add_player_character(new_peer_id)
	
	spawn_existing_entities.rpc_id(new_peer_id)


func add_player_character(peer_id: int):
	connected_peer_ids.append(peer_id)
	var player_char = preload("res://entities/player/player.tscn").instantiate()
	player_char.set_multiplayer_authority(peer_id)
	game_tree.players.add_child(player_char)
	
	# Update Server GUI
	game_tree.add_client_controls(peer_id)


func on_peer_disconnected(peer_id: int):
	print("User ", str(peer_id), " disconnected.")
	remove_existing_player_character.rpc(peer_id)
	var index: int = connected_peer_ids.find(peer_id)
	if index > 0:
		connected_peer_ids.remove_at(index)
	
	# Update Server GUI
	game_tree.remove_client_controls(peer_id)


func kick_peer(peer_id: int):
	print("Kicking user: ", str(peer_id))
	multiplayer.multiplayer_peer.disconnect_peer(peer_id, true)
	on_peer_disconnected(peer_id)


func search_for_game_tree() -> bool:
	for child in get_tree().root.get_children():
		if child is GameTree:
			game_tree = child
	if game_tree == null:
		push_warning("No game tree found")
		return false
	return true


func on_client_name_changed(peer_id: int, new_name: String):
	game_tree.update_client_name(peer_id, new_name)
	print("Client ", peer_id, " changed name to: ", new_name)


func generate_level(seed_str: String):
	level_generator.start_generation(seed_str)


func on_level_tiles_generated(tile_array: String):
	print("Sending ", tile_array.length(), " characters of tiles to clients")
	generated_level_tiles.rpc(tile_array)


@rpc("call_remote")
func add_newly_connected_player_character(_peer_id: int):
	pass


@rpc("call_remote")
func add_previously_connected_player_characters(_peer_ids: Array):
	pass


@rpc("call_remote")
func remove_existing_player_character(_peer_id: int):
	pass


@rpc("any_peer")
func ping_to_server(peer_id: int):
	pong_to_client.rpc_id(peer_id)


@rpc("call_remote")
func pong_to_client():
	pass


@rpc("any_peer")
func report_ping_to_server(peer_id: int, ping: float):
	ping_reported.emit(peer_id, ping)


@rpc("any_peer")
func peer_name_changed(peer_id: int, new_name: String):
	on_client_name_changed(peer_id, new_name)
	pass


## Tutorial for Networked NPCs: https://www.youtube.com/watch?v=87TRvg9TSMc&list=PLRe0l8OGr7rcFTsWm3xyfCOP4NpH72vB1&index=5
@rpc("call_remote")
func spawn_new_entity(_ent_name: String, _global_pos: Vector3):
	pass


@rpc("call_remote")
func spawn_existing_entities(_entities: Array):
	pass


@rpc("call_remote")
func generated_level_tiles(_tile_str: String):
	pass
