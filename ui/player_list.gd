class_name PlayerList
extends Control

## Lists Players and provides controls

@onready var client_controls_list: Container = $MarginContainer/HBoxContainer/ClientControlsList

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


func on_client_name_changed(peer_id: int, new_name: String):
	if !Server.client_mgr.is_valid_name(new_name):
		print("Invalid name from peer: ", peer_id)
		return
	for child in client_controls_list.get_children():
		if child.name == str(peer_id):
			print("Client ", peer_id, " changed name from ", child.player_name_label.text, " to: ", new_name, ".")
			child.update_name(new_name)
