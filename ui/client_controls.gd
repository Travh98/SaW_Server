extends Control

signal kick_peer(peer_id: int)

@onready var peer_id_label: Label = $HBoxContainer/PeerId
@onready var kick_button: Button = $HBoxContainer/KickButton
@onready var ping_label: Label = $HBoxContainer/Ping
@onready var player_name_label: Label = $HBoxContainer/PlayerName


func _ready():
	kick_button.pressed.connect(on_kick_player)


func setup(p: int):
	peer_id_label.text = str(p)


func on_kick_player():
	kick_peer.emit(peer_id_label.text.to_int())
	queue_free()


func update_ping(p: float):
	ping_label.text = str(p) + " ms"


func update_name(n: String):
	player_name_label.text = n
