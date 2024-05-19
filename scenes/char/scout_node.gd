class_name ScoutNode
extends ClassNode

@export var radar_distance : float = 15
var ability_scn = preload("res://scenes/char/scout_ability.tscn")
var tilemap : TileMap

func _ready():
	tilemap = get_tree().current_scene.get_node("TileMap")
	
func ability():
	var array = [Vector2(1,1),Vector2(2,2),Vector2(3,3)]
	var position = Vector2(1,1)
	for e in array:
		if (radar_distance >= abs(position.x - e.x) and radar_distance >= abs(position.y - e.y)):
			var ability_node = ability_scn.instantiate()
			add_child(ability_node)
