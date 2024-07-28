extends Node

## Serverside Player node with matching RPC functions to the players

@onready var multiplayer_synchronizer = $MultiplayerSynchronizer

func _ready():
	multiplayer_synchronizer.set_multiplayer_authority(str(name).to_int())
