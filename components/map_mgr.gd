class_name MapMgr
extends Node

## Manages the map

var map_name: String = "sa_w_level"


func server_changed_map(new_map: String):
	if new_map != map_name:
		map_name = new_map
		Server.map_changed.rpc(map_name)


# For updating individual clients, late joiners
func update_client(peer_id: int):
	Server.map_changed.rpc_id(peer_id, map_name)
