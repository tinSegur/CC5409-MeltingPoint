extends Machine
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.stop()

@rpc("call_local", "any_peer")
func place():
	timer.timeout.connect(spawn_resource)
	placed = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	output.output_scene = load("res://scenes/bullet.tscn")#"res://scenes/materials/material_item.tscn")
	animated_sprite_2d.play()
	timer.start()

func is_valid_place() -> bool:
	var bodies: Array = hitbox.get_overlapping_bodies()
	var resource: bool = false
	if resource_detector.has_overlapping_bodies():
		var tilemap: TileMap = resource_detector.get_overlapping_bodies()[0]
		if is_instance_valid(tilemap):
			var tile = tilemap.get_cell_tile_data(1, tilemap.get_tile_coords(global_position + Vector2(0, 20)))
			if is_instance_valid(tile):
				resource = true
	return ((bodies.size()-1) == 0) and resource

func try_place() -> bool:
	if is_valid_place():
		place.rpc()
		return true
	return false

func cancel_build():
	queue_free()

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
	global_position = pos

func spawn_resource():
	output.generate(0, 2)
	
