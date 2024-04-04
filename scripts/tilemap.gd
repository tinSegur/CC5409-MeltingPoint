extends TileMap

func mine(coords: Vector2):
	var local_coords = to_local(local_to_map(coords))
	var tile: TileData = get_cell_tile_data(0, local_coords)
	if is_instance_valid(tile):
		if tile.get_custom_data("minable") != 0:
			mine_tile.rpc(0, local_coords)

@rpc("any_peer", "call_local", "reliable")
func mine_tile(layer: int, coords: Vector2):
	erase_cell(layer, coords)
