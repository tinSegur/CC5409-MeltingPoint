extends Node2D

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

func ready():
	melting_point = mat_data.melting_point
	breaking_delta = mat_data.breaking_delta
	can_break = mat_data.can_break
	can_melt = mat_data.can_melt
	type = mat_data.type
	melt_icon = mat_data.melt_icon
	solid_icon = mat_data.solid_icon
	
	sprite=$Sprite2D
	tilemap = get_tree().current_scene.get_node("TileMap")
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
	tilemap = get_tree().current_scene.get_node("TileMap")
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
	position.y+=1
