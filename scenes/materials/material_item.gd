extends Area2D

@export var melting_point : int = 2
@export var breaking_delta : float = 2.0 
@export var can_break : bool = false
@export var can_melt : bool = true
@export var type : Statics.Materials
@export var melt_icon : Texture2D
@export var solid_icon : Texture2D
var sprite : Sprite2D
var inner_temp : int = 5 
var delta_temp : float = 0
var tilemap : TileMap

var pipe_coords: Vector2

func ready():
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
	#tilemap = get_tree().current_scene.get_node("TileMap")
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
		queue_free()
		return

func _physics_process(delta: float) -> void:
	
	var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
	if is_instance_valid(pipe):
		var dir = Vector2(pipe.get_custom_data("direction"))
		var new_coords = tilemap.get_tile_coords(global_position)
		var speed = pipe.get_custom_data("pipe_speed")
		
		# speed == 0 => not a pipe
		if speed == 0:
			return
		
		if dir.y == 0:
			if int(global_position.y)%18 < 9:
				global_position.y += speed
			elif int(global_position.y)%18 > 9:
				global_position.y -= speed
			else:
				var next_pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position + dir*6))
				if is_instance_valid(next_pipe):
					var next_coords = tilemap.get_tile_coords(global_position + dir*6)
					if ((!next_pipe.get_custom_data("occupied") and next_pipe.get_custom_data("pipe_speed")!= 0) or next_coords == pipe_coords):
						global_position += dir*speed
		else:
			if int(global_position.x)%18 < 9:
				global_position.x += speed
			elif int(global_position.x)%18 > 9:
				global_position.x -= speed
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
