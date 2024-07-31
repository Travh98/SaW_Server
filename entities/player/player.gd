class_name SyncedPlayer
extends Node

## Serverside Player node with matching RPC functions to the players

@onready var player_sync: PlayerSync = $MultiplayerSynchronizer

func _ready():
	player_sync.set_multiplayer_authority(str(name).to_int())


func get_peer_id() -> int:
	return name.to_int()

