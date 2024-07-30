class_name TttGameMode
extends Node

## Manages the TTT Gamemode

signal game_stage_changed(new_stage: TttGameMode.GameStages)

enum GameStages {
	STAGE_WARMUP,
	STAGE_MAIN,
	STAGE_POST,
}

@onready var warmup_timer: Timer = $WarmupTimer
@onready var main_stage_timer: Timer = $MainStageTimer
@onready var post_round_timer: Timer = $PostRoundTimer

var stage: GameStages = GameStages.STAGE_WARMUP : set = change_stage
var innocents: Array
var traitors: Array

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
			print("Entering warmup round")
		GameStages.STAGE_MAIN:
			start_main_round()
		GameStages.STAGE_POST:
			start_post_round()
	
	game_stage_changed.emit(stage)


func start_gamemode():
	print("Starting TTT GameMode")
	warmup_timer.start()


func on_warmup_finished():
	warmup_timer.stop()
	
	# Check if enough players to start
	if GameTree.players.get_child_count() < 2:
		print("Not enough players to start TTT")
		warmup_timer.start()
		return
	
	change_stage(GameStages.STAGE_MAIN)


func start_main_round():
	print("Starting main TTT Round")
	main_stage_timer.start()
	
	traitors.clear()
	innocents.clear()
	
	var players: Array = GameTree.players.get_children()
	var first_traitor: SyncedPlayer = players.pick_random()
	traitors.append(first_traitor)
	players.remove_at(players.find(first_traitor))
	
	for innocent: SyncedPlayer in players:
		innocents.append(innocent)
	
	var debug_traitors: String = "Traitors: "
	for traitor: SyncedPlayer in traitors:
		debug_traitors += str(traitor.get_peer_id()) + " "
		Server.assign_player_faction.rpc(traitor.get_peer_id(), "Traitor")
	var debug_innocents: String = "Innocents: "
	for innocent: SyncedPlayer in innocents:
		debug_innocents += str(innocent.get_peer_id()) + " "
		Server.assign_player_faction.rpc(innocent.get_peer_id(), "Innocent")
	print(debug_traitors, ". ", debug_innocents, ".")
	


func on_main_stage_finished():
	main_stage_timer.stop()
	change_stage(GameStages.STAGE_POST)
	pass


func start_post_round():
	print("Entering post-round")
	post_round_timer.start()
	
	var players: Array = GameTree.players.get_children()
	for player in players:
		Server.assign_player_faction.rpc(player.get_peer_id(), "Innocent")


func on_post_round_finished():
	post_round_timer.stop()
	change_stage(GameStages.STAGE_MAIN)
	pass


func check_if_team_is_alive(arr_of_player_ids: Array):
	for peer_id in arr_of_player_ids:
		for player in get_parent().players:
			pass
