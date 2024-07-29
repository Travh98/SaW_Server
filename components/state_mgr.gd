class_name StateMgr
extends Node

## Manages the state of the server

signal game_mode_changed(mode: StateMgr.ServerMode)

enum ServerMode {
	MODE_PVE,
	MODE_TTT,
}

var server_mode: ServerMode = ServerMode.MODE_PVE : set = set_server_mode


func server_changed_mode(new_mode_str: String):
	var new_mode: ServerMode = ServerMode.get(new_mode_str)
	if new_mode == null:
		push_warning("Got invalid new mode string: ", new_mode_str)
	server_mode = new_mode


func set_server_mode(new_mode: ServerMode):
	if new_mode != server_mode:
		server_mode = new_mode
		
		game_mode_changed.emit(server_mode)
		Server.mode_changed.rpc(ServerMode.keys()[server_mode])
