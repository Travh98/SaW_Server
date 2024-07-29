extends Node

## GameTree for replicating the Client's scene tree, used for synchronization

@onready var players: Node = $Players
@onready var npcs: Node = $CurrentLevel/Level/NPCs
@onready var client_controls_list: Control = $PlayerList/MarginContainer/HBoxContainer/ClientControlsList
@onready var server_controls: ServerControls = $ServerControls
#
#var player_dict: Dictionary

func _ready():
	Server.ping_reported.connect(on_ping_reported)


func add_client_controls(peer_id: int):
	var controls = preload("res://ui/client_controls.tscn").instantiate()
	client_controls_list.add_child(controls)
	controls.setup(peer_id)
	controls.name = str(peer_id)
	controls.kick_peer.connect(Server.client_mgr.kick_peer)


func remove_client_controls(peer_id: int):
	for child in client_controls_list.get_children():
		if child.name == str(peer_id):
			child.queue_free()


func on_ping_reported(id: int, p: float):
	for child in client_controls_list.get_children():
		if child.name == str(id):
			child.update_ping(p)


func update_client_name(peer_id: int, new_name: String):
	for child in client_controls_list.get_children():
		if child.name == str(peer_id):
			child.update_name(new_name)


#func get_player(peer_id: int) -> Player:
	#
