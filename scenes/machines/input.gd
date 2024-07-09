extends Node2D

var retcodes = Statics.INPUT_CODES

@onready var parent_machine : Machine = get_parent()

func receive_item(item : MPMaterial, liquid: bool):
	var code = parent_machine.input_resource(item, liquid)
	
	match code:
		retcodes.NOTACCEPT:
			pass
		retcodes.ACCEPT:
			pass



func _on_hitbox_area_entered(area : Area2D):
	if parent_machine.placed:
		receive_item(area.mat_data, area.liquid)
		area.destroy()
