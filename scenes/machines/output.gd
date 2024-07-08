class_name Output
extends Node2D
@onready var marker_2d = $Marker2D

#@export var possible_outputs: Array[PackedScene]
var output_scene: PackedScene = preload("res://scenes/materials/material_item.tscn")
var output_type : MPMaterial
var item_container: Node2D
var tilemap: TileMap
#var outputs_amount: int = 0
@onready var timer = $Timer

var stable_mode : bool = false
var output_temp : int = 0

var crafter_mode : bool = false
var ambient_mode : bool = false

func _ready():
	tilemap = get_tree().current_scene.get_node("TileMap")
	item_container = get_tree().current_scene.get_node("%Items")

func valid_pipe():
	var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
	if is_instance_valid(pipe):
		if !pipe.get_custom_data("occupied"):
			return true
	return false

func generate(index: int, amount: int, state : int = Statics.Material_states.SOLID):
	while amount > 0:
		var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
		if is_instance_valid(pipe):
			if pipe.get_custom_data("pipe_speed") == 0:
				return
			if !pipe.get_custom_data("occupied"):
				var item = output_scene.instantiate()
				item.mat_data = output_type
				if crafter_mode:
					item.can_melt = false
				item.global_position = global_position
				item.tilemap = tilemap
				item.pipe_coords = tilemap.get_tile_coords(global_position)
				if state != Statics.Material_states.SOLID:
					item.liquid = true
				item_container.add_child(item, true)
				if state != Statics.Material_states.SOLID:
					item.inner_temp = item.melting_point + 1
				
				if ambient_mode:
					var tile_coords = tilemap.get_tile_coords(global_position)
					var tile: TileData= tilemap.get_cell_tile_data(3, tile_coords)
					if is_instance_valid(tile):
						var new_temp=tile.get_custom_data("temperature")
						item.inner_temp = new_temp
				
				if stable_mode:
					item.inner_temp = output_temp
		#else:
			#Debug.sprint("invalid pipe")

		timer.start()
		amount -= 1
		await timer.timeout
