class_name NpcMgr
extends Node

## Manages NPCs on the Server


func spawn_red_knight():
	var knight = preload("res://entities/npcs/npc.tscn").instantiate()
	knight.set_multiplayer_authority(1)
	GameTree.npcs.add_child(knight)
	Server.client_spawn_red_knight.rpc()


func spawn_blue_knight():
	var knight = preload("res://entities/npcs/npc.tscn").instantiate()
	knight.set_multiplayer_authority(1)
	GameTree.npcs.add_child(knight)
	Server.client_spawn_blue_knight.rpc()
