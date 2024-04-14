class_name ClassNode
extends Node2D

@export var stat_dict = {
			"gravity" : 200,
			"jump_speed" : 135,
			"speed" : 85,
			"acceleration" : 200,
			"mine_time" : 0.5,
			"mining_radius" : 400
}

@export var player_sprite : Texture
@export var ui_sprite : Texture

func get_stats() -> Dictionary:
	return stat_dict

func get_player_sprite() -> Texture:
	return player_sprite
