extends Area2D
class_name Item

var melting_point : int = 2
var breaking_delta : float = 100.0
var can_break : bool = false
var can_melt : bool = true
var melt_speed : float = 0.02
var type : Statics.Materials
var melt_icon : Texture2D
var solid_icon : Texture2D

var inner_temp : float = 0 

var delta_temp : float = 0
var tilemap : TileMap
var mat_data : MPMaterial
var broken = false
var liquid = false

var pipe_coords: Vector2

@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	melting_point = mat_data.melting_point
	breaking_delta = mat_data.breaking_delta
	can_break = mat_data.can_break
	can_melt = mat_data.can_melt
	type = mat_data.type
	melt_speed = mat_data.melt_speed/1000
	melt_icon = mat_data.melt_icon
	solid_icon = mat_data.solid_icon
	inner_temp = mat_data.default_temp
	
	
	var tile_coords = tilemap.get_tile_coords(global_position)
	tilemap.set_cell(0, pipe_coords, 5, tilemap.get_cell_atlas_coords(0, pipe_coords),1)
	var tile : TileData = tilemap.get_cell_tile_data(3, tile_coords)
	
	if liquid:
		sprite.set_texture(melt_icon)
		inner_temp = (9+melting_point)/2
	else:
		sprite.set_texture(solid_icon)
		inner_temp = melting_point/2


# Called every frame. 'delta' is the elapsed time since the previous frame.

#func _process(delta):
	#var tile_coords = tilemap.get_tile_coords(global_position)
	#var tile: TileData= tilemap.get_cell_tile_data(3, tile_coords)
	#if is_instance_valid(tile):
		#var new_temp=tile.get_custom_data("temperature")
		#change_temp(new_temp)

func change_temp(new_temp : int):
	sprite = $Sprite2D
	inner_temp = move_toward(inner_temp, new_temp, max((new_temp - inner_temp)*melt_speed, melt_speed))

	delta_temp=new_temp-inner_temp
	if can_melt :
		
		# Color logic
		if inner_temp > (melting_point-1) and !liquid:
			modulate = Color(1,0.6,0.6)
		elif inner_temp < (melting_point) and liquid:
			modulate = Color(0.6,0.6,1)
		else:
			modulate = Color(1,1,1)
		
		# Sprite and state logic
		if inner_temp <= (melting_point-1) and liquid:
			#inner_temp=new_temp
			liquid = false
			sprite.set_texture(solid_icon)
			return
		if inner_temp >= melting_point and !liquid:
			#inner_temp=new_temp
			liquid = true
			sprite.set_texture(melt_icon)
			return
	if can_break and delta_temp >= breaking_delta:
		destroy()
		return

func _physics_process(delta: float) -> void:
	var tile_coords = tilemap.get_tile_coords(global_position)
	var tile: TileData= tilemap.get_cell_tile_data(3, tile_coords)
	if is_instance_valid(tile):
		var new_temp=tile.get_custom_data("temperature")
		change_temp(new_temp)
	
	if broken:
		queue_free()
		return
	
	var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
	if is_instance_valid(pipe):
		var dir = Vector2(pipe.get_custom_data("direction"))
		var new_coords = tilemap.get_tile_coords(global_position)
		var speed = pipe.get_custom_data("pipe_speed")
		
		# speed == 0 => not a pipe
		if speed == 0:
			return
		
		if dir.y == 0:
			if abs(int(global_position.y)%18) < 9:
				global_position.y += speed * (1 if (sign(global_position.y) == 0) else sign(global_position.y))
			elif abs(int(global_position.y)%18) > 9:
				global_position.y -= speed * sign(global_position.y)
			else:
				var next_pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position + dir*6))
				if is_instance_valid(next_pipe):
					var next_coords = tilemap.get_tile_coords(global_position + dir*6)

					if ((!next_pipe.get_custom_data("occupied") and next_pipe.get_custom_data("pipe_speed")!= 0 and Vector2(next_pipe.get_custom_data("direction"))!= -1*dir) or next_coords == pipe_coords):
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
		  
					if ((!next_pipe.get_custom_data("occupied") and next_pipe.get_custom_data("pipe_speed")!= 0 and Vector2(next_pipe.get_custom_data("direction"))!= -1*dir) or next_coords == pipe_coords):
						global_position += dir*speed
					
		if new_coords != pipe_coords:
			tilemap.set_cell(0, pipe_coords, 5, tilemap.get_cell_atlas_coords(0, pipe_coords),0)
			tilemap.set_cell(0, new_coords, 5, tilemap.get_cell_atlas_coords(0, new_coords),1)
			pipe_coords = new_coords

			

@rpc("any_peer","call_local","reliable")
func destroy():
	broken = true
	var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
	if is_instance_valid(pipe):
		tilemap.set_cell(0, pipe_coords, 5, tilemap.get_cell_atlas_coords(0, pipe_coords),0)
