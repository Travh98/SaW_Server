class_name ClientMgr
extends Node

## Manages Clients

signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int)

var connected_peer_ids = []
var player_names: Dictionary

func on_peer_connected(new_peer_id: int):
	print("User ", str(new_peer_id), " connected.")
	
	# Spawn existing players for the new client
	Server.add_previously_connected_player_characters.rpc_id(new_peer_id, connected_peer_ids)
	# Spawn a new player for the new client
	Server.add_newly_connected_player_character.rpc(new_peer_id)
	# Spawn a corresponding player node for the server to keep synced
	add_player_character(new_peer_id)
	
	client_connected.emit(new_peer_id)


func on_peer_disconnected(peer_id: int):
	print("User ", str(peer_id), " disconnected.")
	
	# Tell the clients to unload this player
	Server.remove_existing_player_character.rpc(peer_id)
	
	# Remove our stored peer_id
	var found_id: bool = false
	for index in range(connected_peer_ids.size()):
		if connected_peer_ids[index] == peer_id:
			connected_peer_ids.remove_at(index)
			found_id = true
			break
	if !found_id:
		print("Tried removing peer_id ", peer_id, " for disconnected player, but could not find it.")
	
	for player in GameTree.players.get_children():
		if player.name == str(peer_id):
			player.queue_free()
	
	client_disconnected.emit(peer_id)


func add_player_character(peer_id: int):
	# Store the peer_id
	connected_peer_ids.append(peer_id)
	
	var player_char = preload("res://entities/player/player.tscn").instantiate()
	player_char.set_multiplayer_authority(peer_id)
	player_char.name = str(peer_id)
	GameTree.players.add_child(player_char)  # TODO make this a signal


func kick_peer(peer_id: int):
	print("Kicking user: ", str(peer_id))
	
	multiplayer.multiplayer_peer.disconnect_peer(peer_id) # optionally force
	on_peer_disconnected(peer_id)


func on_player_name_changed(peer_id: int, player_name: String):
	player_names[peer_id] = player_name
	#print("Storing player name ", player_name, " for peer id: ", peer_id)


func is_valid_name(in_name: String) -> bool:
	if in_name.replace(" ", "").is_empty():
		return false
	return true


func update_client(peer_id: int):
	#print("Updating late joiner client: ", peer_id, " with the names of all ", GameTree.get_child_count(), " peers")
	for player in GameTree.players.get_children():
		var player_peer_id: int = player.name.to_int()
		if !player_names.has(player_peer_id):
			continue
		var player_peer_name: String = player_names[player_peer_id]
		Server.peer_name_changed.rpc_id(peer_id, 
			player_peer_id, player_peer_name)
		#print("Sending Peer ", peer_id, " name ", player_peer_name)
