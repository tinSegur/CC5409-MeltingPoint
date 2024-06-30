extends Output

var output_temp : int = 0

func generate(index : int, amount : int, state : int = Statics.Material_states.SOLID):
	while amount > 0:
		var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
		if is_instance_valid(pipe):
			
			if pipe.get_custom_data("pipe_speed") == 0:
				return
			if !pipe.get_custom_data("occupied"):
				var item = output_scene.instantiate()
				item.mat_data = output_type
				item.global_position = global_position
				item.tilemap = tilemap
				item.pipe_coords = tilemap.get_tile_coords(global_position)
				if state != Statics.Material_states.SOLID:
					item.liquid = true
				item_container.add_child(item, true)
				item.inner_temp = output_temp
				
			amount -= 1
		else:
			Debug.sprint("no pipes")
