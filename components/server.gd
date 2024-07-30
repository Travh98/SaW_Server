extends Node

## Server interface. Connects serverside managers and holds the RPC functions
## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s

signal player_name_changed(peer_id: int, new_name: String)
signal ping_reported(peer_id: int, ping: float)

@onready var enet_server_starter: EnetServer = $EnetServerStarter
@onready var client_mgr: ClientMgr = $ClientMgr
@onready var state_mgr: StateMgr = $StateMgr
@onready var map_mgr: MapMgr = $MapMgr
@onready var level_generator: LevelGenerator = $LevelGenerator
@onready var server_controls: ServerControls = $ServerGui/ServerControls
@onready var player_list: PlayerList = $ServerGui/PlayerList
@onready var npc_mgr: NpcMgr = $NpcMgr


func _ready():
	enet_server_starter.start_server()
	
	player_name_changed.connect(player_list.on_client_name_changed)
	
	multiplayer.multiplayer_peer.peer_connected.connect(client_mgr.on_peer_connected)
	multiplayer.multiplayer_peer.peer_disconnected.connect(client_mgr.on_peer_disconnected)
	
	client_mgr.client_connected.connect(player_list.add_client_controls)
	client_mgr.client_disconnected.connect(player_list.remove_client_controls)
	
	## Update late joiners with the current level info
	client_mgr.client_connected.connect(level_generator.send_tile_data)
	client_mgr.client_connected.connect(map_mgr.update_client)
	client_mgr.client_connected.connect(state_mgr.update_client)
	
	server_controls.start_level_gen.connect(level_generator.start_generation)
	server_controls.spawn_red_knight.connect(npc_mgr.spawn_red_knight)
	server_controls.spawn_blue_knight.connect(npc_mgr.spawn_blue_knight)


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
	player_name_changed.emit(peer_id, new_name)
	pass


## Tutorial for Networked NPCs: https://www.youtube.com/watch?v=87TRvg9TSMc&list=PLRe0l8OGr7rcFTsWm3xyfCOP4NpH72vB1&index=5


@rpc("call_remote", "reliable")
func generated_level_tiles(_tile_str: String):
	pass


# Tell the client to spawn a red knight
@rpc("call_remote")
func client_spawn_red_knight():
	pass


@rpc("call_remote")
func client_spawn_blue_knight():
	pass


@rpc("call_remote", "reliable")
func mode_changed(_mode_name: String):
	pass


@rpc("call_remote", "reliable")
func map_changed(_map_name: String):
	pass


@rpc("call_remote")
func assign_player_faction(_peer_id: int, _faction_name: String):
	pass


@rpc("any_peer")
func send_player_data(peer_id: int, player_name: String, player_color: Color):
	print("Server sees player ", peer_id, " ", player_name, " with color: ", player_color)
	peer_name_changed.rpc(peer_id, player_name)
	pass
