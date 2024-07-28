extends Control

signal kick_peer(peer_id: int)

@onready var peer_id_label: Label = $HBoxContainer/PeerId
@onready var kick_button: Button = $HBoxContainer/KickButton


func _ready():
	kick_button.pressed.connect(on_kick_player)


func setup(p: int):
	peer_id_label.text = str(p)


func on_kick_player():
	kick_peer.emit(peer_id_label.text.to_int())
	queue_free()
