class_name EngineerNode
extends ClassNode

@export_file var overclocker_path : String
 
var overclocker_placed : bool = false
var player : Player


func _ready():
	player = get_parent()

func ability():
	if !Game.overclocker_placed:
		player.build_scene = overclocker_path
		player.on_machine_selected()
	else:
		player.place_error("Overclocker already exists", player.global_position + Vector2(0.0, -20))
	
