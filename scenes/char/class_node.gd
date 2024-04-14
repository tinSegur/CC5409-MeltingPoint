class_name ClassNode
extends Node2D

@export var stat_dict = {
			"gravity" : 98,
			"jump_speed" : 80,
			"speed" : 60,
			"acceleration" : 60,
			"mine_time" : 0.5,
			"mining_radius" : 400
}

@export var player_sprite : Texture
@export var ui_sprite : Texture

func get_stats() -> Dictionary:
	return stat_dict

func get_player_sprite() -> Texture:
	return player_sprite
