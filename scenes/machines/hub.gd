class_name Hub
extends Machine



@onready var inventory = get_parent().get_node("Inventory")

func _ready():
	placed = true


func input_resource(item : MPMaterial) -> Statics.INPUT_CODES:
	if multiplayer.is_server():
		inventory.add_resource.rpc(item.type)
	return Statics.INPUT_CODES.ACCEPT
