class_name PlayerData
extends Node

## Holds player data

signal player_name_changed(peer_id: int, player_name: String)

var player_data = {}


func _ready():
	pass


func on_client_connected(peer_id: int):
	# Create dictionary entry for this new peer
	if !player_data.has(peer_id):
		player_data[peer_id] = {
			"name": "unset",
			"peer_id": peer_id,
			"health": 100,
			"color": Color.PINK,
		}
	print("Added new playerdata entry: ", player_data[peer_id])
	
	# Inform late joiners
	update_client(peer_id)


func on_client_disconnected(peer_id: int):
	# Remove dictionary entry for this user
	if player_data.has(peer_id):
		print("Removing playerdata entry: ", player_data[peer_id])
		player_data.erase(peer_id)


func recieve_player_name(peer_id: int, player_name: String):
	player_data[peer_id]["name"] = player_name
	
	player_name_changed.emit(peer_id, player_name)
	# Update all clients
	Server.peer_name_changed.rpc(peer_id, player_name)


func is_valid_name(in_name: String) -> bool:
	if in_name.replace(" ", "").is_empty():
		return false
	return true


func update_client(peer_id: int):
	Server.send_player_data_from_server.rpc_id(peer_id, player_data)
