class_name GameTree
extends Node

@onready var players: Node = $Players
@onready var client_controls_list: Control = $PlayerList/MarginContainer/HBoxContainer/ClientControlsList

func add_client_controls(peer_id: int):
	var controls = preload("res://ui/client_controls.tscn").instantiate()
	client_controls_list.add_child(controls)
	controls.setup(peer_id)
	controls.name = str(peer_id)
	controls.kick_peer.connect(Server.kick_peer)


func remove_client_controls(peer_id: int):
	for child in client_controls_list.get_children():
		if child.name == str(peer_id):
			child.queue_free()
