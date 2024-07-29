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
	
	# Give data to late joiners
	
	#map_changed.rpc_id(new_peer_id, map_name)
	#mode_changed.rpc_id(new_peer_id, mode_name)


func on_peer_disconnected(peer_id: int):
	print("User ", str(peer_id), " disconnected.")
	
	# Tell the clients to unload this player
	Server.remove_existing_player_character.rpc(peer_id)
	
	# Remove our stored peer_id
	var index: int = connected_peer_ids.find(peer_id)
	if index > 0:
		connected_peer_ids.remove_at(index)
	else:
		print("Tried removing peer_id ", peer_id, " for disconnected player, but could not find it.")
	
	client_disconnected.emit(peer_id)


func add_player_character(peer_id: int):
	# Store the peer_id
	connected_peer_ids.append(peer_id)
	
	var player_char = preload("res://entities/player/player.tscn").instantiate()
	player_char.set_multiplayer_authority(peer_id)
	GameTree.players.add_child(player_char)
	
	# Update Server GUI
	GameTree.add_client_controls(peer_id)


func kick_peer(peer_id: int):
	print("Kicking user: ", str(peer_id))
	
	multiplayer.multiplayer_peer.disconnect_peer(peer_id) # optionally force
	on_peer_disconnected(peer_id)
