extends TileMap

var progress = 0

func _input(event):
	if event.is_action_pressed("show_temp"):
		set_layer_enabled(3, !is_layer_enabled(3))

func mine(coords: Vector2):
	
	var resource: TileData = get_cell_tile_data(1, coords)
	if is_instance_valid(resource):
		var atlas_coords = get_cell_atlas_coords(1, coords)
		var res: int
		match atlas_coords:
			Vector2i(10,1):
				res = Statics.Materials.IRON
			_:
				res = -1
		Game.get_player_instance(multiplayer.get_unique_id()).mine_resource(res)
		return
	
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
		erase_cell(2, coords)
	else:
		set_cell(2, coords, 1, Vector2(level - 1, 0))

func get_tile_coords(coords):
	return to_local(local_to_map(coords))

@rpc("any_peer", "call_local", "reliable")
func mine_tile(layer: int, coords: Vector2):
	erase_cell(layer, coords)
	
@rpc("authority", "call_local", "reliable")
func generate_resource(ore: String, cell_position: Vector2i):
	var ore_atlas_coordinates : Vector2
	
	match ore:
		"Iron":
			ore_atlas_coordinates = Vector2(10,1)
		"Gold":
			ore_atlas_coordinates = Vector2(10,0)
		"Unstable_Ore":
			ore_atlas_coordinates = Vector2(8,1)
		_:
			return
	
	set_cell(1, cell_position, 0, ore_atlas_coordinates)
	var atlas_pos = get_cell_atlas_coords(0, cell_position)
	set_cell(0, cell_position, 0, atlas_pos, 1)

