class_name ScoutNode
extends ClassNode

@export var radar_distance : float = 15
var ability_scn = preload("res://scenes/char/scout_ability.tscn")
var used_positions
var player : Player
var player_position : Vector2

func _ready():
	player = get_parent()

func ability():
	used_positions = get_tree().current_scene.get_used_positions()
	player_position = player.get_player_tile_position()
	
	for ore in range(0,3):
		for e in used_positions[ore]:
			if (radar_distance >= abs(player_position.x - e.x) and 
				radar_distance >= abs(player_position.y - e.y)):
					var ability_node = ability_scn.instantiate()
					ability_node.ore = ore
					ability_node.ore_postition  = e
					add_child(ability_node)
					ability_node.set_direction(player_position, e)
