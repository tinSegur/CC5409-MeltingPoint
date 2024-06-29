extends Area2D

@export var icon : Texture2D

var tilemap : TileMap
var pipe_coords: Vector2

@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	tilemap = get_tree().current_scene.get_node("TileMap")
	var tile_coords = get_tile_coords(global_position)
	sprite.set_texture(icon)

func _physics_process(delta: float) -> void:
	var tile_coords = get_tile_coords(global_position)
	var pipe = tilemap.get_cell_tile_data(0, tile_coords)
	if is_instance_valid(pipe):
		var dir = Vector2(pipe.get_custom_data("direction"))
		var new_coords = get_tile_coords(global_position)
		var speed = pipe.get_custom_data("pipe_speed")
		
		if dir.y == 0:
			if abs(int(global_position.y)%18) < 9:
				global_position.y += speed * (1 if (sign(global_position.y) == 0) else sign(global_position.y))
			elif abs(int(global_position.y)%18) > 9:
				global_position.y -= speed * sign(global_position.y)
			else:
				var next_pipe = tilemap.get_cell_tile_data(0, get_tile_coords(global_position + dir*6))
				if is_instance_valid(next_pipe):
					var next_coords = get_tile_coords(global_position + dir*6)

					if ((next_pipe.get_custom_data("pipe_speed")!= 0 and Vector2(next_pipe.get_custom_data("direction"))!= -1*dir) or next_coords == pipe_coords):
						global_position += dir*speed
		else:
			if int(abs(global_position.x))%18 < 9:
				global_position.x += speed * (1 if (sign(global_position.x) == 0) else sign(global_position.x))
			elif int(abs(global_position.x))%18 > 9:
				global_position.x -= speed * sign(global_position.x)
			else:
				var next_pipe = tilemap.get_cell_tile_data(0, get_tile_coords(global_position + dir*6))
				if is_instance_valid(next_pipe):
					var next_coords = get_tile_coords(global_position + dir*6)
		  
					if ((next_pipe.get_custom_data("pipe_speed")!= 0 and Vector2(next_pipe.get_custom_data("direction"))!= -1*dir) or next_coords == pipe_coords):
						global_position += dir*speed
					
		if new_coords != pipe_coords:
			pipe_coords = new_coords

func get_tile_coords(coords):
	return Vector2(floori(global_position.x/18), floori(global_position.y/18))
