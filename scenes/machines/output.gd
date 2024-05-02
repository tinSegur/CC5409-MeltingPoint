extends Node2D
@onready var marker_2d = $Marker2D

#@export var possible_outputs: Array[PackedScene]
var output_scene: PackedScene
var output_type : MPMaterial
var item_container: Node2D
var tilemap: TileMap
#var outputs_amount: int = 0
@onready var timer = $Timer

func _ready():
	tilemap = get_tree().current_scene.get_node("TileMap")
	item_container = get_tree().current_scene.get_node("%Items")

func generate(index: int, amount: int):
	while amount > 0:

		var pipe = tilemap.get_cell_tile_data(0, tilemap.get_tile_coords(global_position))
		if is_instance_valid(pipe):
			if !pipe.get_custom_data("occupied"):
				var item = output_scene.instantiate()
				item.mat_data = output_type
				item.global_position = global_position
				item.tilemap = tilemap
				item.pipe_coords = tilemap.get_tile_coords(global_position)
				item_container.add_child(item, true)
				if is_multiplayer_authority():
					var inventory = get_tree().current_scene.get_node("Inventory")
					inventory.add_resource.rpc_id(1, Statics.Materials.IRON, 1)
		else:
			Debug.sprint("invalid pipe")

		timer.start()
		amount -= 1
		await timer.timeout
