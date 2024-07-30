extends Node

## GameTree for replicating the Client's scene tree, used for synchronization

@onready var players: Node = $Players
@onready var npcs: Node = $CurrentLevel/Level/NPCs

