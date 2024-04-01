extends TileMap


func _physics_process(delta):
	
	if Input.is_action_just_pressed("mine"):
		var coords: Vector2 = local_to_map(get_viewport().get_mouse_position())
		var tile: TileData = get_cell_tile_data(0, coords)
		if is_instance_valid(tile):
			if tile.get_custom_data("minable") != 0:
				mine_tile.rpc(0, coords)

@rpc("any_peer", "call_local", "reliable")
func mine_tile(layer: int, coords: Vector2):
	erase_cell(layer, coords)
