extends Machine


var hub_mats : Array
var ind = 0

@export var output_time : float = 1.0

@onready var hub = get_tree().current_scene.get_node("Hub")
@onready var inventory : Inventory = get_tree().current_scene.get_node("Inventory")
@onready var sprite : Sprite2D = $Sprite2D
@onready var hub_detector = $HubDetector

func _ready():
	hub_mats = inventory.materials
	sprite.set_texture(hub_mats[ind].solid_icon)
	timer.wait_time = output_time
	timer.timeout.connect(try_extract)

@rpc("call_local", "any_peer")
func place():
	placed = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	output.output_type = output_type
	output.output_scene = load("res://scenes/materials/material_item.tscn")
	timer.start()

func current_mat() -> MPMaterial:
	return hub_mats[floor(ind/2)]

func current_state() -> Statics.Material_states:
	return current_mat().states[ind%2]

func try_extract():
	if inventory.check_stock(current_mat().type, 1, current_state()):
		if output.valid_pipe():
			output.generate(current_mat().type, 1, current_state())
			inventory.remove_stock(current_mat().type, 1, current_state())


func is_valid_place() -> bool:
	var bodies: Array = hitbox.get_overlapping_bodies()
	var resource: bool = false
	if hub_detector.has_overlapping_bodies():
		for b in hub_detector.get_overlapping_bodies():
			var bh = b as Hub
			if is_instance_valid(bh):
				resource = true
	return ((bodies.size()-1) == 0) and resource

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mine") && placed:
		update_index.rpc()

@rpc("any_peer","call_local","reliable")
func update_index():
	ind = (ind+1)%(2*hub_mats.size())
	if ind%2 == 0:
		sprite.set_texture(hub_mats[floor(ind/2)].solid_icon)
	else:
		sprite.set_texture(hub_mats[floor(ind/2)].melt_icon)
