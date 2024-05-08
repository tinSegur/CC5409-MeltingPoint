extends TileMap

var progress = 0

var player: Player

var pipes_index = {
	# Codificacion binaria: dddd iiii
	# dddd = direccion
	# iiii = inputs
	# xxxx = arriba, abajo, izquierda, derecha
	
	# Pipes hacia arriba
	"128": 1,
	"129": 10,
	"130": 11,
	"131": 25,
	"132": 1,
	"133": 13,
	"134": 14,
	"135": 21,
	
	# Pipes hacia abajo
	"64": 2,
	"65": 6,
	"66": 7,
	"67": 26,
	"72": 2,
	"73": 15,
	"74": 16,
	"75": 22,
	
	# Pipes hacia la izquierda
	"32": 4,
	"33": 4,
	"36": 8,
	"37": 19,
	"40": 12,
	"41": 20,
	"44": 28, #Falta un tile
	"45": 24,
	
	# Pipes hacia la derecha
	"16": 3,
	"18": 3,
	"20": 5,
	"22": 17,
	"24": 9,
	"26": 18,
	"28": 27, #Falta un tile
	"30": 23
}

func _input(event):
	if event.is_action_pressed("show_temp"):
		set_layer_enabled(3, !is_layer_enabled(3))

func mine(coords: Vector2):
	
	var resource: TileData = get_cell_tile_data(1, coords)
	if is_instance_valid(resource):
		var atlas_coords = get_cell_atlas_coords(1, coords)
		var res: int
		match atlas_coords:
			Vector2i(0,0):
				res = Statics.Materials.IRON
			_:
				res = -1
		player.mine_resource(res)
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
			ore_atlas_coordinates = Vector2(0,0)
		"Gold":
			ore_atlas_coordinates = Vector2(10,0)
		"Unstable_Ore":
			ore_atlas_coordinates = Vector2(8,1)
		_:
			return
	
	set_cell(1, cell_position, 3, ore_atlas_coordinates)
	var atlas_pos = get_cell_atlas_coords(0, cell_position)
	set_cell(0, cell_position, 0, atlas_pos, 1)

func place_tile(coords: Vector2i, index: int):
	if !is_instance_valid(get_cell_tile_data(0, coords)):
		place.rpc(coords, index)
		if (index > 0):
			var dir = Vector2i.ZERO
			match index:
				1:
					dir = Vector2i(0,-1)
				2:
					dir = Vector2i(0,1)
				3:
					dir = Vector2i(1,0)
				4:
					dir = Vector2i(-1,0)
			var pipe = get_cell_tile_data(0, coords + dir)
			if is_instance_valid(pipe):
				if pipe.get_custom_data("direction") != dir*-1:
					update_pipe(coords + dir)
			pipe = get_cell_tile_data(0, coords + Vector2i(0,-1))
			if is_instance_valid(pipe):
				if pipe.get_custom_data("direction") == Vector2i(0,1):
					update_pipe(coords + Vector2i(0,-1))
			pipe = get_cell_tile_data(0, coords + Vector2i(0,1))
			if is_instance_valid(pipe):
				if pipe.get_custom_data("direction") == Vector2i(0,-1):
					update_pipe(coords + Vector2i(0,1))
			pipe = get_cell_tile_data(0, coords + Vector2i(-1,0))
			if is_instance_valid(pipe):
				if pipe.get_custom_data("direction") == Vector2i(1,0):
					update_pipe(coords + Vector2i(-1,0))
			pipe = get_cell_tile_data(0, coords + Vector2i(1,0))
			if is_instance_valid(pipe):
				if pipe.get_custom_data("direction") == Vector2i(-1,0):
					update_pipe(coords + Vector2i(1,0))
		update_pipe(coords)
		return true
	return false

func update_pipe(coords: Vector2i):
	var pipe = get_cell_tile_data(0, coords)
	var dir = pipe.get_custom_data("direction")
	var other: TileData
	var key = 0
	
	match dir:
		Vector2i(0,-1):
			key = 128
		Vector2i(0,1):
			key = 64
		Vector2i(-1,0):
			key = 32
		Vector2i(1,0):
			key = 16
	
	other = get_cell_tile_data(0, coords + Vector2i(-1,0))
	if is_instance_valid(other) and dir !=  Vector2i(-1,0):
		if other.get_custom_data("direction") == Vector2i(1,0):
			key += 2
	other = get_cell_tile_data(0, coords + Vector2i(1,0))
	if is_instance_valid(other) and dir !=  Vector2i(1,0):
		if other.get_custom_data("direction") == Vector2i(-1,0):
			key += 1
	other = get_cell_tile_data(0, coords + Vector2i(0,-1))
	if is_instance_valid(other) and dir !=  Vector2i(0,-1):
		if other.get_custom_data("direction") == Vector2i(0,1):
			key += 8
	other = get_cell_tile_data(0, coords + Vector2i(0,1))
	if is_instance_valid(other) and dir !=  Vector2i(0,1):
		if other.get_custom_data("direction") == Vector2i(0,-1):
			key += 4
	place.rpc(coords, pipes_index[str(key)])

@rpc("call_local", "reliable", "any_peer")
func place(coords: Vector2i, index: int):
	if index == 0:
		set_cell(0, coords, 4, Vector2i(0,2))
	elif index <= 12:
		set_cell(0, coords, 5, Vector2i(index - 1, 0))
	elif index <= 24:
		set_cell(0, coords, 5, Vector2i(index - 13, 1))
	else:
		set_cell(0, coords, 5, Vector2i(index - 25, 2))

func show_preview(coords: Vector2i, index: int):
	clear_previews()
	if !is_instance_valid(get_cell_tile_data(0, coords)):
		if index == 0:
			set_cell(4, coords, 4, Vector2i(0,2), 1)
		else:
			set_cell(4, coords, 5, Vector2i(index - 1, 0))

func clear_previews():
	var previews = get_used_cells(4)
	for coords in previews:
		erase_cell(4, coords)
