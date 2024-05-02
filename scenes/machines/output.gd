extends Node2D
@onready var marker_2d = $Marker2D

#@export var possible_outputs: Array[PackedScene]
var output_scene: PackedScene
var output_type : MPMaterial
var item_container: Node2D
#var outputs_amount: int = 0
@onready var timer = $Timer

func _ready():
	item_container = get_tree().current_scene.get_node("%Items")

func generate(index: int, amount: int):

	while amount > 0:
		var item = output_scene.instantiate()
		item.mat_data = MPMaterial
		item.global_position = global_position
		item_container.add_child(item, true)
		if is_multiplayer_authority():
			var inventory = get_tree().current_scene.get_node("Inventory")
			inventory.add_resource.rpc_id(1, Statics.Materials.IRON, 1)
		timer.start()
		amount -= 1
		await timer.timeout
