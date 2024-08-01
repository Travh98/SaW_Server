class_name FreezeOnHitMgr
extends Node

## Freezes client games whenever someone is hit

@onready var freeze_timer: Timer = $FreezeTimer

var is_active: bool = false : set = set_freeze_enabled


func _ready():
	freeze_timer.timeout.connect(on_freeze_timeout)
	freeze_timer.one_shot = true


func set_freeze_time(freeze_time: float):
	freeze_timer.wait_time = freeze_time / 1000.0


func on_player_hit(_peer_id: int, _health: int):
	if !is_active:
		return
	Server.set_game_freeze.rpc(true)
	freeze_timer.start()


func on_freeze_timeout():
	Server.set_game_freeze.rpc(false)


func set_freeze_enabled(enable: bool):
	is_active = enable
