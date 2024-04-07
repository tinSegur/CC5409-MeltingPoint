extends TileMap

var progress = 0

func mine(coords: Vector2):
	var tile: TileData = get_cell_tile_data(0, coords)
	if is_instance_valid(tile):
		if tile.get_custom_data("minable") != 0:
			mine_tile.rpc(0, coords)

func breaking(coords: Vector2, level: int):
	if level != progress:
		if level==0:
			break_anim.rpc(coords, 0)
			progress = 0
		elif level >= 4:
			break_anim.rpc(coords, 0)
			mine(coords)
			progress = 0
		else:
			break_anim.rpc(coords, level)
			progress = level

@rpc("any_peer", "call_local", "reliable")
func break_anim(coords: Vector2, level: int):
	if level == 0 :
		erase_cell(1, coords)
	else:
		set_cell(1, coords, 1, Vector2(level - 1, 0))

func get_tile_coords(coords):
	return to_local(local_to_map(coords))

@rpc("any_peer", "call_local", "reliable")
func mine_tile(layer: int, coords: Vector2):
	erase_cell(layer, coords)
