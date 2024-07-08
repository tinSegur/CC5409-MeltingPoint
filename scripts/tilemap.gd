extends TileMap

var progress = 0

var player: Player
@onready var build_stream_player_2d = $BuildStreamPlayer2D
@onready var mine_stream_player_2d = $MineStreamPlayer2D

var pipes_index = {
	# Codificacion binaria: dddd iiii
	# dddd = direccion
	# iiii = inputs
	# xxxx = arriba, abajo, izquierda, derecha
	
	# Pipes hacia arriba
	"128": 0,
	"129": 9,
	"130": 10,
	"131": 24,
	"132": 0,
	"133": 12,
	"134": 13,
	"135": 20,
	
	# Pipes hacia abajo
	"64": 1,
	"65": 5,
	"66": 6,
	"67": 25,
	"72": 1,
	"73": 14,
	"74": 15,
	"75": 21,
	
	# Pipes hacia la izquierda
	"32": 3,
	"33": 3,
	"36": 7,
	"37": 18,
	"40": 11,
	"41": 19,
	"44": 27,
	"45": 23,
	
	# Pipes hacia la derecha
	"16": 2,
	"18": 2,
	"20": 4,
	"22": 16,
	"24": 8,
	"26": 17,
	"28": 26,
	"30": 22
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
			Vector2i(1,0):
				res = Statics.Materials.GOLD
			Vector2i(3,0):
				res = Statics.Materials.CRYSTALS
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
	mine_stream_player_2d.global_position = to_global(map_to_local(coords))
	mine_stream_player_2d.play()
	
@rpc("authority", "call_local", "reliable")
func generate_resource(ore: String, cell_position: Vector2i, pure: bool):
	if !is_instance_valid(get_cell_tile_data(0, cell_position)):
		return
	
	var ore_atlas_coordinates : Vector2
	
	match ore:
		"Iron":
			ore_atlas_coordinates = Vector2(0,0)
		"Gold":
			ore_atlas_coordinates = Vector2(1,0)
		"Crystal":
			ore_atlas_coordinates = Vector2(3,0)
		_:
			return
	
	if !pure:
		ore_atlas_coordinates.y = 1
	
	set_cell(1, cell_position, 3, ore_atlas_coordinates)
	var atlas_pos = get_cell_atlas_coords(0, cell_position)
	set_cell(0, cell_position, 0, atlas_pos, 1)

func place_tile(coords: Vector2i, index: int):
	if !is_instance_valid(get_cell_tile_data(0, coords)):
		place.rpc(coords, index)
		if (index < 28):
			var dir = Vector2i.ZERO
			match index:
				0:
					dir = Vector2i(0,-1)
				1:
					dir = Vector2i(0,1)
				2:
					dir = Vector2i(1,0)
				3:
					dir = Vector2i(-1,0)
			var pipe = get_cell_tile_data(0, coords + dir)
			if is_instance_valid(pipe):
				if pipe.get_custom_data("direction") != dir*-1 and pipe.get_custom_data("direction") != Vector2i.ZERO:
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
		elif (index == 35):
			var ladder = get_cell_tile_data(0, coords + Vector2i(0,1))
			if is_instance_valid(ladder):
				if get_cell_source_id(0, coords + Vector2i(0,1)) == 4 and get_cell_atlas_coords(0, coords + Vector2i(0,1)) == Vector2i(0,2):
					place.rpc(coords + Vector2i(0,1), 36)
			ladder = get_cell_tile_data(0, coords + Vector2i(0,-1))
			if is_instance_valid(ladder):
				if get_cell_source_id(0, coords + Vector2i(0,1)) == 4 and (get_cell_atlas_coords(0, coords + Vector2i(0,1)) == Vector2i(0,2) or get_cell_atlas_coords(0, coords + Vector2i(0,1)) == Vector2i(1,2)):
					place.rpc(coords, 36)
		return true
	return false

func update_pipe(coords: Vector2i):
	##Debug.sprint(coords)
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
	if index >= 37:
		set_cell(0, coords, 4, Vector2i(index - 37, 3))
	elif index >= 35:
		set_cell(0, coords, 4, Vector2i(index - 35, 2))
	elif index >= 33:
		set_cell(0, coords, 4, Vector2i(index - 33, 1))
	elif index >= 28:
		set_cell(0, coords, 4, Vector2i(index - 28, 0))
	elif index <= 11:
		set_cell(0, coords, 5, Vector2i(index, 0))
	elif index <= 23:
		set_cell(0, coords, 5, Vector2i(index - 12, 1))
	else:
		set_cell(0, coords, 5, Vector2i(index - 24, 2))
	build_stream_player_2d.global_position = to_global(map_to_local(coords))
	build_stream_player_2d.play()

func show_preview(coords: Vector2i, index: int):
	clear_previews()
	if !is_instance_valid(get_cell_tile_data(0, coords)):
		if index >= 37:
			set_cell(4, coords, 4, Vector2i(index - 37, 3), 1)
		elif index >= 35:
			set_cell(4, coords, 4, Vector2i(index - 35, 2))
		elif index >= 33:
			set_cell(4, coords, 4, Vector2i(index - 33, 1), 1)
		elif index >= 28:
			set_cell(4, coords, 4, Vector2i(index - 28, 0), 1)
		else:
			set_cell(4, coords, 5, Vector2i(index, 0))

func clear_previews():
	var previews = get_used_cells(4)
	for coords in previews:
		erase_cell(4, coords)

@rpc("any_peer", "call_local", "reliable")
func purify_ore(coords: Vector2i):
	var ore_atlas_coordinates : Vector2i = get_cell_atlas_coords(1, coords)
	ore_atlas_coordinates.y = 0
	set_cell(1, coords, 3, ore_atlas_coordinates)
