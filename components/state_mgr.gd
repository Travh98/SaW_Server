class_name StateMgr
extends Node

## Manages the state of the server

signal game_mode_changed(mode: StateMgr.ServerMode)

enum ServerMode {
	MODE_PVE,
	MODE_TTT,
}

@onready var ttt_game_mode: TttGameMode = $"../GameModes/TttGameMode"

var server_mode: ServerMode = ServerMode.MODE_PVE : set = set_server_mode


func _ready():
	game_mode_changed.connect(on_game_mode_changed)


func server_changed_mode(new_mode_str: String):
	var new_mode = ServerMode.get(new_mode_str)
	if new_mode == null:
		push_warning("Got invalid new mode string: ", new_mode_str)
		return
	
	server_mode = new_mode


func set_server_mode(new_mode: ServerMode):
	if new_mode != server_mode:
		server_mode = new_mode
		
		print("ServerMode: ", ServerMode.keys()[server_mode])
		game_mode_changed.emit(server_mode)
		Server.mode_changed.rpc(ServerMode.keys()[server_mode])


func on_game_mode_changed(new_mode: ServerMode):
	match new_mode:
		ServerMode.MODE_PVE:
			pass
		ServerMode.MODE_TTT:
			ttt_game_mode.start_gamemode()


func update_client(peer_id: int):
	Server.mode_changed.rpc_id(peer_id, ServerMode.keys()[server_mode])
