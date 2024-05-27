class_name Hub
extends Machine



@onready var inventory = get_parent().get_node("Inventory")
@onready var sprite : Sprite2D = $Sprite2D

var inv_variety : int = 0

func _ready():
	placed = true
	inventory.stock_variety.connect(update_sprite)



func input_resource(item : MPMaterial) -> Statics.INPUT_CODES:
	if multiplayer.is_server():
		inventory.add_resource.rpc(item.type)
	return Statics.INPUT_CODES.ACCEPT




func update_sprite(b : bool):
	if b && inv_variety < sprite.get_hframes():
		inv_variety += 1
	elif inv_variety > 0:
		inv_variety -= 1
	sprite.set_frame(inv_variety)
