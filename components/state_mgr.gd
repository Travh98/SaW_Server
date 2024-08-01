class_name StateMgr
extends Node

## Manages the state of the server

enum ServerMode {
	MODE_PVE,
	MODE_TTT,
	MODE_FFA,
}

@onready var ttt_game_mode: TttGameMode = $"../GameModes/TttGameMode"
@onready var free_for_all: FfaGameMode = $"../GameModes/FreeForAll"

var server_mode: ServerMode = ServerMode.MODE_PVE : set = set_server_mode


func _ready():
	pass


func server_changed_mode(new_mode_str: String):
	var new_mode = ServerMode.get(new_mode_str)
	if new_mode == null:
		push_warning("Got invalid new mode string: ", new_mode_str)
		return
	
	server_mode = new_mode


func set_server_mode(new_mode: ServerMode):
	if new_mode != server_mode:
		var old_mode: ServerMode = server_mode
		
		server_mode = new_mode
		print("ServerMode: ", ServerMode.keys()[server_mode])
		
		game_mode_changed(old_mode, server_mode)
		Server.mode_changed.rpc(ServerMode.keys()[server_mode])


func game_mode_changed(old_mode: ServerMode, new_mode: ServerMode):
	if old_mode == new_mode:
		return
	
	match old_mode:
		ServerMode.MODE_PVE:
			pass
		ServerMode.MODE_TTT:
			ttt_game_mode.stop_gamemode()
		ServerMode.MODE_FFA:
			free_for_all.stop_gamemode()
	
	match new_mode:
		ServerMode.MODE_PVE:
			for player in GameTree.players.get_children():
				Server.assign_player_faction.rpc(player.name.to_int(), "Player")
			pass
		ServerMode.MODE_TTT:
			ttt_game_mode.start_gamemode()
		ServerMode.MODE_FFA:
			free_for_all.start_gamemode()


func update_client(peer_id: int):
	Server.mode_changed.rpc_id(peer_id, ServerMode.keys()[server_mode])
