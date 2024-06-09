extends Machine



@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.stop()

@onready var resource_detector = $ResourceDetector



@rpc("call_local", "any_peer")
func place():
	timer.timeout.connect(spawn_resource)
	placed = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)

	output.output_type = output_type

	output.output_scene = load("res://scenes/materials/material_item.tscn")

	animated_sprite_2d.play()
	timer.start()

func is_valid_place() -> bool:
	var bodies: Array = hitbox.get_overlapping_bodies()
	var tiles = resource_detector.get_overlapping_bodies()
	var resource: bool = false
	if resource_detector.has_overlapping_bodies():
		var tilemap: TileMap = tiles[0]
		if is_instance_valid(tilemap):
			var tile_coords = tilemap.get_tile_coords(global_position + Vector2(0, 20).rotated(rotation))
			var tile = tilemap.get_cell_tile_data(1, tile_coords)
			if is_instance_valid(tile):
				if tilemap.get_cell_atlas_coords(1, tile_coords) == Vector2i(0,0):
					resource = true
	#Debug.sprint(str((bodies.size() - 1) == 0) + "," + str(resource))
	#Debug.sprint(offset_vec)
	return ((bodies.size()-1) == 0) and resource

func try_place() -> bool:
	if is_valid_place():
		place.rpc()
		return true
	return false

func cancel_build():
	queue_free()

func _physics_process(delta):
	super(delta)

@rpc("call_local", "any_peer")
func send_pos(pos: Vector2):
	global_position = pos

func spawn_resource():
	output.generate(0, 1)
	
