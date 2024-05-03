extends Node2D

var retcodes = Statics.INPUT_CODES

@onready var parent_machine = get_parent()

func receive_item(item : MPMaterial):
	var code = parent_machine.input_resource(item)
	
	match code:
		retcodes.NOTACCEPT:
			pass
		retcodes.ACCEPT:
			pass



func _on_hitbox_area_entered(area : Area2D):
	receive_item(area.mat_data)
	area.queue_free()
