class_name PlayerData
extends Node

## Holds player data

signal player_name_changed(peer_id: int, player_name: String)
signal player_died(peer_id: int)

var player_data = {}


func _ready():
	pass


func on_client_connected(peer_id: int):
	# Create dictionary entry for this new peer
	if !player_data.has(peer_id):
		create_default_entry(peer_id)
	
	# Inform late joiners
	update_client(peer_id)


func on_client_disconnected(peer_id: int):
	# Remove dictionary entry for this user
	if player_data.has(peer_id):
		print("Removing playerdata entry: ", player_data[peer_id])
		player_data.erase(peer_id)


func recieve_player_name(peer_id: int, player_name: String):
	if player_data[peer_id]["name"] == player_name:
		return
	
	print(peer_id, " changing name: ", player_data[peer_id]["name"], " to ", player_name)
	player_data[peer_id]["name"] = player_name
	
	player_name_changed.emit(peer_id, player_name)
	# Update all clients
	Server.peer_name_changed.rpc(peer_id, player_name)


func set_player_health(peer_id: int, health: int):
	if !player_data.has(peer_id): return
	
	var previous_hp: int = player_data[peer_id]["health"]
	
	player_data[peer_id]["health"] = health
	Server.player_health_changed.rpc(peer_id, player_data[peer_id]["health"])
	
	if previous_hp > 0 and health <= 0:
		print("Player has died: ", player_data[peer_id]["name"])
		player_died.emit(peer_id)



func damage_player(damager_id: int, target_id: int, damage: int):
	set_player_health(target_id, player_data[target_id]["health"] - damage)
	
	print(player_data[damager_id]["name"], " (hp: ", player_data[damager_id]["health"], ") hurt ", 
		player_data[target_id]["name"], " (hp: ", player_data[target_id]["health"], ")")


func respawn_all_players():
	for peer_id in player_data:
		set_player_health(peer_id, 100)
	Server.respawn_players.rpc()


func revive_all_players():
	for peer_id in player_data:
		set_player_health(peer_id, 100)


func is_valid_name(in_name: String) -> bool:
	if in_name.replace(" ", "").is_empty():
		return false
	return true


func update_client(peer_id: int):
	# Send the full player data dictionary to this Client
	Server.send_player_data_from_server.rpc_id(peer_id, player_data)


func create_default_entry(peer_id: int):
	player_data[peer_id] = {
			"name": "unset",
			"peer_id": peer_id,
			"health": 100,
			"color": Color.PINK,
		}


func get_player_name(peer_id: int) -> String:
	if !player_data.has(peer_id): return "error"
	return player_data[peer_id]["name"]


func is_player_alive(peer_id: int) -> bool:
	if !player_data.has(peer_id): return false
	return player_data[peer_id]["health"] > 0
