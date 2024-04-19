extends StaticBody2D

var placed = false
@export var builder_id: int = 0
@onready var hitbox = $Hitbox
@onready var resource_detector = $ResourceDetector

func place():
	placed = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func is_valid_place() -> bool:
	var bodies: Array = hitbox.get_overlapping_bodies()
	var resource: bool = false
	if resource_detector.has_overlapping_bodies():
		var tilemap: TileMap = resource_detector.get_overlapping_bodies()[0]
		if is_instance_valid(tilemap):
			var tile = tilemap.get_cell_tile_data(1, tilemap.get_tile_coords(global_position + Vector2(0, 20)))
			#Debug.sprint(tile)
			if is_instance_valid(tile):
				resource = true
	return ((bodies.size()-1) == 0) and resource

#func _ready():
	#$MultiplayerSynchronizer.synchronized.connect(_on_synchronice)

func _input(event):
	if event.is_action_pressed("mine"):
		if is_valid_place():
			place()

func _physics_process(delta):
	if !placed:
		if builder_id == multiplayer.get_unique_id():
			var mouse_pos = Vector2i(get_global_mouse_position())
			var build_pos = Vector2i(mouse_pos.x - mouse_pos.x%18 + 9 * (1 if (sign(mouse_pos.x) == 0) else sign(mouse_pos.x)), 
									 mouse_pos.y - mouse_pos.y%18 + 2)
			send_pos.rpc_id(1, build_pos)
			
		if is_valid_place():
			modulate = Color(1,1,1,0.8)
		else:
			modulate = Color(1,0.1,0.1,0.8)

@rpc("call_local", "any_peer")
func send_pos(pos: Vector2):
	Debug.sprint(pos)
	global_position = pos

#func _on_synchronice():
	#set_multiplayer_authority(builder_id, true)