extends Node

## Server interface
## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s

signal ping_reported(peer_id: int, ping: float)
signal game_mode_changed(mode: ServerMode)

enum ServerMode {
	MODE_PVE,
	MODE_TTT,
}

@onready var enet_server_starter: EnetServer = $EnetServerStarter
@onready var client_mgr: ClientMgr = $ClientMgr
@onready var level_generator: LevelGenerator = $LevelGenerator


var tile_array_serialized: String
var mode_name: String = "pve"
var map_name: String = "sa_w_level"
var server_mode: ServerMode = ServerMode.MODE_PVE


func _ready():
	enet_server_starter.start_server()
	
	multiplayer.multiplayer_peer.peer_connected.connect(client_mgr.on_peer_connected)
	multiplayer.multiplayer_peer.peer_disconnected.connect(client_mgr.on_peer_disconnected)
	
	client_mgr.client_disconnected.connect(GameTree.remove_client_controls)
	client_mgr.client_connected.connect(level_generator.send_tile_data)
	




func on_client_name_changed(peer_id: int, new_name: String):
	GameTree.update_client_name(peer_id, new_name)
	print("Client ", peer_id, " changed name to: ", new_name)


func spawn_red_knight():
	var knight = preload("res://entities/npcs/npc.tscn").instantiate()
	knight.set_multiplayer_authority(1)
	GameTree.npcs.add_child(knight)
	client_spawn_red_knight.rpc()


func spawn_blue_knight():
	var knight = preload("res://entities/npcs/npc.tscn").instantiate()
	knight.set_multiplayer_authority(1)
	GameTree.npcs.add_child(knight)
	client_spawn_blue_knight.rpc()


func server_changed_mode(new_mode: String):
	if new_mode != mode_name:
		mode_name = new_mode
		on_game_mode_changed(mode_name)
		mode_changed.rpc(mode_name)


func server_changed_map(new_map: String):
	if new_map != map_name:
		map_name = new_map
		map_changed.rpc(map_name)


func on_game_mode_changed(mode_str: String):
	match mode_str:
		"pve":
			server_mode = ServerMode.MODE_PVE
		"ttt":
			server_mode = ServerMode.MODE_TTT
		_:
			push_warning("Unknown game mode: ", mode_str)
	game_mode_changed.emit(server_mode)


@rpc("call_remote", "reliable")
func add_newly_connected_player_character(_peer_id: int):
	pass


@rpc("call_remote", "reliable")
func add_previously_connected_player_characters(_peer_ids: Array):
	pass


@rpc("call_remote", "reliable")
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


@rpc("any_peer", "reliable")
func peer_name_changed(peer_id: int, new_name: String):
	on_client_name_changed(peer_id, new_name)
	pass


## Tutorial for Networked NPCs: https://www.youtube.com/watch?v=87TRvg9TSMc&list=PLRe0l8OGr7rcFTsWm3xyfCOP4NpH72vB1&index=5
#@rpc("call_remote")
#func spawn_new_entity(_ent_name: String, _global_pos: Vector3):
	#pass


#@rpc("call_remote")
#func spawn_existing_entities(_entities: Array):
	#pass


@rpc("call_remote", "reliable")
func generated_level_tiles(_tile_str: String):
	pass


@rpc("call_remote")
func client_spawn_red_knight():
	pass


@rpc("call_remote")
func client_spawn_blue_knight():
	pass


@rpc("call_remote", "reliable")
func mode_changed(mode_name: String):
	pass


@rpc("call_remote", "reliable")
func map_changed(map_name: String):
	pass
