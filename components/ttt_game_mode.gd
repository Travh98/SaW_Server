extends Node

## Manages the TTT Gamemode

enum GameStages {
	STAGE_WARMUP,
	STAGE_MAIN,
	STAGE_POST,
}

@onready var warmup_timer: Timer = $WarmupTimer
@onready var main_stage_timer: Timer = $MainStageTimer
@onready var post_round_timer: Timer = $PostRoundTimer

var stage: GameStages = GameStages.STAGE_WARMUP : set = change_stage
var innocents: Array[int] # Array of peer ids
var traitors: Array[int]

func _ready():
	#Server.game_mode_changed.connect(on_game_mode_changed)
	
	warmup_timer.timeout.connect(on_warmup_finished)
	main_stage_timer.timeout.connect(on_main_stage_finished)
	post_round_timer.timeout.connect(on_post_round_finished)


func change_stage(new_stage: GameStages):
	stage = new_stage 
	print("Gamemode TTT changing to ", GameStages.keys()[stage])
	match stage:
		GameStages.STAGE_WARMUP:
			print("Entering warmup round")
		GameStages.STAGE_MAIN:
			pass
		GameStages.STAGE_POST:
			pass

func on_warmup_finished():
	# Check if enough players to start
	if get_parent().players.get_child_count() >= 2:
		stage = GameStages.STAGE_MAIN
	pass


func on_main_stage_finished():
	pass


func on_post_round_finished():
	pass


func check_if_team_is_alive(arr_of_player_ids: Array):
	for peer_id in arr_of_player_ids:
		for player in get_parent().players:
			pass
