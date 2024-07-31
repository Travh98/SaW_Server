class_name TttGameMode
extends Node

## Manages the TTT Gamemode

signal game_stage_changed(new_stage: TttGameMode.GameStages)
signal respawn_all_players()
signal revive_all_players()

enum GameStages {
	STAGE_WARMUP,
	STAGE_MAIN,
	STAGE_POST,
}

@onready var warmup_timer: Timer = $WarmupTimer
@onready var main_stage_timer: Timer = $MainStageTimer
@onready var post_round_timer: Timer = $PostRoundTimer

var stage: GameStages = GameStages.STAGE_WARMUP : set = change_stage
var innocent_players: Array
var traitor_players: Array

func _ready():
	warmup_timer.timeout.connect(on_warmup_finished)
	main_stage_timer.timeout.connect(on_main_stage_finished)
	post_round_timer.timeout.connect(on_post_round_finished)
	


# Perform actions on entering each stage
func change_stage(new_stage: GameStages):
	stage = new_stage 
	print("Gamemode TTT changing to ", GameStages.keys()[stage])
	
	match stage:
		GameStages.STAGE_WARMUP:
			start_warmup()
		GameStages.STAGE_MAIN:
			start_main_round()
		GameStages.STAGE_POST:
			start_post_round()
	
	game_stage_changed.emit(stage)
	Server.gamemode_stage_changed.rpc(GameStages.keys()[stage])


func start_gamemode():
	print("Starting TTT GameMode")
	change_stage(GameStages.STAGE_WARMUP)


func stop_gamemode():
	print("Stopping TTT GameMode")
	change_stage(GameStages.STAGE_WARMUP)
	warmup_timer.stop()
	main_stage_timer.stop()
	post_round_timer.stop()


func start_warmup():
	print("Waiting for enough players to start TTT")
	main_stage_timer.stop()
	post_round_timer.stop()
	
	revive_all_players.emit()
	
	warmup_timer.start()
	Server.gamemode_stage_time_left.rpc(warmup_timer.time_left)
	
	for player: SyncedPlayer in GameTree.players.get_children():
		Server.assign_player_faction.rpc(player.get_peer_id(), "Peaceful")


func on_warmup_finished():
	warmup_timer.stop()
	
	# Check if enough players to start
	if GameTree.players.get_child_count() < 2:
		start_warmup()
		return
	
	change_stage(GameStages.STAGE_MAIN)


func start_main_round():
	print("Starting main TTT Round")
	main_stage_timer.start()
	Server.gamemode_stage_time_left.rpc(main_stage_timer.time_left)
	
	revive_all_players.emit()
	
	traitor_players.clear()
	innocent_players.clear()
	
	var players: Array = GameTree.players.get_children()
	if players.size() < 2:
		print("Not enough players to start TTT")
		change_stage(GameStages.STAGE_WARMUP)
		return
	var first_traitor: SyncedPlayer = players.pick_random()
	traitor_players.append(first_traitor)
	players.remove_at(players.find(first_traitor))
	
	for innocent: SyncedPlayer in players:
		innocent_players.append(innocent)
	
	var debug_traitors: String = "Traitors: "
	for traitor: SyncedPlayer in traitor_players:
		debug_traitors += str(traitor.get_peer_id()) + " "
		Server.assign_player_faction.rpc(traitor.get_peer_id(), "Traitor")
	var debug_innocents: String = "Innocents: "
	for innocent: SyncedPlayer in innocent_players:
		debug_innocents += str(innocent.get_peer_id()) + " "
		Server.assign_player_faction.rpc(innocent.get_peer_id(), "Innocent")
	print(debug_traitors, ". ", debug_innocents, ".")


func on_main_stage_finished():
	main_stage_timer.stop()
	
	calculate_win()
	
	change_stage(GameStages.STAGE_POST)
	pass


func start_post_round():
	print("Entering post-round")
	post_round_timer.start()
	Server.gamemode_stage_time_left.rpc(post_round_timer.time_left)


func on_post_round_finished():
	post_round_timer.stop()
	respawn_all_players.emit()
	change_stage(GameStages.STAGE_WARMUP)


func on_client_connected(peer_id: int):
	if stage != GameStages.STAGE_MAIN:
		return
	
	await get_tree().create_timer(3).timeout
	
	# Kill the player that joins
	print("Killing the client who joined mid-round: ", peer_id)
	Server.player_data.set_player_health(peer_id, 0)

func on_client_disconnected(peer_id: int):
	if stage != GameStages.STAGE_MAIN:
		# Can join/leave anytime during warmup or post
		return
	
	print("Client ", peer_id, " left mid-round while we had ", 
		traitor_players.size(), " traitors and ", innocent_players.size(), " innocents.")
	var traitor_client: SyncedPlayer = get_player_in_team(peer_id, traitor_players)
	if traitor_client:
		if traitor_players.size() <= 1:
			print("The last traitor has left the game during the round")
			traitor_players.erase(traitor_client)
			on_main_stage_finished()
			return
		traitor_players.erase(traitor_client)
		return
	var innocent_client: SyncedPlayer = get_player_in_team(peer_id, innocent_players)
	if innocent_client:
		if innocent_players.size() <= 1:
			print("The last innocent has left the game during the round")
			innocent_players.erase(innocent_client)
			on_main_stage_finished()
			return
		innocent_players.erase(innocent_client)
		return
	


func on_player_died(peer_id: int):
	if stage != GameStages.STAGE_MAIN:
		return
	
	print("Player ", peer_id, " died, checking if won")
	if get_player_in_team(peer_id, traitor_players):
		if !check_if_team_is_alive(traitor_players):
			on_main_stage_finished()
	if get_player_in_team(peer_id, innocent_players):
		if !check_if_team_is_alive(innocent_players):
			on_main_stage_finished()


func check_if_team_is_alive(arr_of_players: Array) -> bool:
	if arr_of_players.is_empty():
		return false
	for player: SyncedPlayer in arr_of_players:
		if Server.player_data.is_player_alive(player.get_peer_id()):
			return true
	return false


func get_player_in_team(peer_id: int, array_of_players: Array) -> SyncedPlayer:
	for player: SyncedPlayer in array_of_players:
		if player.get_peer_id() == peer_id:
			return player
	return null


func calculate_win():
	if check_if_team_is_alive(innocent_players):
		print("Innocents win!")
		Server.ttt_team_won.rpc(false)
	else:
		print("Traitors win!")
		Server.ttt_team_won.rpc(true)
	
