class_name ClientMgr
extends Node

## Manages Clients

signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int)

var connected_peer_ids = []

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
		push_warning("Failed to remove peer id for peer: ", peer_id)
	
	var found_player_obj: bool = false
	for player in GameTree.players.get_children():
		if player.name == str(peer_id):
			player.queue_free()
			found_player_obj = true
	if !found_player_obj:
		push_warning("Failed to remove player object for peer: ", peer_id)
	
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

