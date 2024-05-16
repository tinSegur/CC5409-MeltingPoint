extends Area2D
class_name Item

var melting_point : int = 2
var breaking_delta : float = 100.0
var can_break : bool = false
var can_melt : bool = true
var type : Statics.Materials
var melt_icon : Texture2D
var solid_icon : Texture2D
var sprite : Sprite2D
var inner_temp : int = 5 
var delta_temp : float = 0
var tilemap : TileMap
var mat_data : MPMaterial
var broken = false

var pipe_coords: Vector2

func _ready():
	melting_point = mat_data.melting_point
	breaking_delta = mat_data.breaking_delta
	can_break = mat_data.can_break
	can_melt = mat_data.can_melt
	type = mat_data.type
	melt_icon = mat_data.melt_icon
	solid_icon = mat_data.solid_icon
	
	sprite=$Sprite2D
	var tile_coords = tilemap.get_tile_coords(global_position)
	var tile : TileData = tilemap.get_cell_tile_data(3, tile_coords)
	if is_instance_valid(tile):
		inner_temp=tile.get_custom_data("temperature")
		if can_melt :
			if inner_temp>=melting_point :
				sprite.set_texture(melt_icon)
			else :
				sprite.set_texture(solid_icon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tile_coords = tilemap.get_tile_coords(global_position)
	var tile: TileData= tilemap.get_cell_tile_data(3, tile_coords)
	if is_instance_valid(tile):
		var new_temp=tile.get_custom_data("temperature")
		change_temp(new_temp)

func change_temp(new_temp : int):
	sprite = $Sprite2D
	delta_temp=new_temp-inner_temp
	if can_melt :
		if inner_temp < melting_point and new_temp >= melting_point:
			inner_temp=new_temp
			sprite.set_texture(melt_icon)
			return
		if inner_temp >= melting_point and new_temp < melting_point:
			inner_temp=new_temp
			sprite.set_texture(solid_icon)
			return
	if can_break and delta_temp >= breaking_delta:
		destroy()
		return

func _physics_process(delta: float) -> void:
	
	if broken:
		queue_free()
		return
	
	var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
	if is_instance_valid(pipe):
		
		var dir = Vector2(pipe.get_custom_data("direction"))
		var new_coords = tilemap.get_tile_coords(global_position)
		var speed = pipe.get_custom_data("pipe_speed")
		
		#if broken:
			#Debug.sprint("Broken item")
			#tilemap.set_cell(0, pipe_coords, 5, tilemap.get_cell_atlas_coords(0, pipe_coords),0)
			#queue_free()
			#return
		
		# speed == 0 => not a pipe
		if speed == 0:
			return
		
		#var build_pos = Vector2i(mouse_pos.x - mouse_pos.x%18 + 9 * (1 if (sign(mouse_pos.x) == 0) else sign(mouse_pos.x)), 
			 					#mouse_pos.y - mouse_pos.y%18 + 2)
		
		if dir.y == 0:
			if abs(int(global_position.y)%18) < 9:
				global_position.y += speed * (1 if (sign(global_position.y) == 0) else sign(global_position.y))
			elif abs(int(global_position.y)%18) > 9:
				global_position.y -= speed * sign(global_position.y)
			else:
				var next_pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position + dir*6))
				if is_instance_valid(next_pipe):
					var next_coords = tilemap.get_tile_coords(global_position + dir*6)
					if ((!next_pipe.get_custom_data("occupied") and next_pipe.get_custom_data("pipe_speed")!= 0) or next_coords == pipe_coords):
						global_position += dir*speed
		else:
			if int(abs(global_position.x))%18 < 9:
				global_position.x += speed * (1 if (sign(global_position.x) == 0) else sign(global_position.x))
			elif int(abs(global_position.x))%18 > 9:
				global_position.x -= speed * sign(global_position.x)
			else:
				var next_pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position + dir*6))
				if is_instance_valid(next_pipe):
					var next_coords = tilemap.get_tile_coords(global_position + dir*6)
					if ((!next_pipe.get_custom_data("occupied") and next_pipe.get_custom_data("pipe_speed")!= 0) or next_coords == pipe_coords):
						global_position += dir*speed
					
		if new_coords != pipe_coords:
			tilemap.set_cell(0, pipe_coords, 5, tilemap.get_cell_atlas_coords(0, pipe_coords),0)
			tilemap.set_cell(0, new_coords, 5, tilemap.get_cell_atlas_coords(0, new_coords),1)
			pipe_coords = new_coords
		else:
			tilemap.set_cell(0, pipe_coords, 5, tilemap.get_cell_atlas_coords(0, pipe_coords),1)

@rpc("any_peer","call_local","reliable")
func destroy():
	broken = true
	var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
	if is_instance_valid(pipe):
		tilemap.set_cell(0, pipe_coords, 5, tilemap.get_cell_atlas_coords(0, pipe_coords),0)
