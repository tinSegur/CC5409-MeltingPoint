extends Machine

@export var cable_recipe : Recipe
@export var plate_recipe : Recipe

var cableMode : bool = true
@onready var internal_inv : InternalInventory = $InternalInventory
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	animated_sprite.stop()

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mine"):
		cableMode = !cableMode

func input_resource(item : MPMaterial, liquid : bool) -> Statics.INPUT_CODES:
	if liquid:
		internal_inv.add_stock(item.id, 1, Statics.Material_states.LIQUID)
	else:
		internal_inv.add_stock(item.id, 1, Statics.Material_states.SOLID)
	
	return Statics.INPUT_CODES.ACCEPT

func check_recipe_reqs(r : Recipe) -> bool:
	var ret : bool
	for id in Statics.Materials:
		ret = ret and internal_inv.check_stock(id, r.melt_reqs[id], Statics.Material_states.LIQUID)
		ret = ret and internal_inv.check_stock(id, r.solid_reqs[id], Statics.Material_states.SOLID)
	return ret

func _on_timer_timeout():
	if cableMode && check_recipe_reqs(cable_recipe):
		output.output_type = cable_recipe.material
		output.generate(0, 1)
	elif !cableMode && check_recipe_reqs(plate_recipe):
		output.output_type = plate_recipe.material
		output.generate(0, 1)
