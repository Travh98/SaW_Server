class_name FfaGameMode
extends Node

var scores = {}
var is_active: bool = false


func _ready():
	pass


func start_gamemode():
	scores.clear()
	is_active = true
	for player: SyncedPlayer in GameTree.players.get_children():
		initialize_peer_score(player.get_peer_id())
		Server.assign_player_faction.rpc(player.get_peer_id(), "Player")
		Server.player_data.respawn_player(player.get_peer_id())
	print("Starting Free For All. Scores: ", scores)
	Server.set_temporary_message.rpc("Free For All!")


func stop_gamemode():
	print("Free for All ended. Scores: ", scores)
	is_active = false
	scores.clear()


func on_player_died(peer_id: int):
	if !is_active: return
	if !scores.has(peer_id):
		initialize_peer_score(peer_id)
	if scores.has(peer_id):
		scores[peer_id] -= 1
		Server.set_temporary_message.rpc(get_score_msg())
		
		await get_tree().create_timer(2).timeout
		Server.player_data.respawn_player(peer_id)


func get_score_msg() -> String:
	var msg: String = ""
	for peer_id in scores:
		var p_name: String = Server.player_data.get_player_name(peer_id)
		if p_name != "error":
			msg += p_name + ": " + str(scores[peer_id]) + "\n"
	return msg


func on_client_connected(peer_id: int):
	initialize_peer_score(peer_id)


func initialize_peer_score(peer_id: int):
	scores[peer_id] = 0
