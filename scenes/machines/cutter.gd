extends Machine

@onready var internal_inv : InternalInventory = $InternalInventory




func input_resource(item : MPMaterial, liquid : bool):
	if liquid:
		internal_inv.add_stock(item.id, 1, Statics.Material_states.LIQUID)
	else:
		internal_inv.add_stock(item.id, 1, Statics.Material_states.SOLID)

