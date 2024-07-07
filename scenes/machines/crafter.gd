extends Machine

@export var recipe : Recipe

@onready var internal_inv : InternalInventory = $InternalInventory
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	print("build crafter")
	animated_sprite.stop()

func place():
	super.place()
	animated_sprite.play()
	timer.start()

func input_resource(item : MPMaterial, liquid : bool) -> Statics.INPUT_CODES:
	if item.type == Statics.Materials.CRYSTALS:
		if liquid:
			internal_inv.add_stock(item.type, 1, Statics.Material_states.SOLID)
	else:
		if liquid:
			internal_inv.add_stock(item.type, 1, Statics.Material_states.LIQUID)
		else:
			internal_inv.add_stock(item.type, 1, Statics.Material_states.SOLID)
	return Statics.INPUT_CODES.ACCEPT

func check_recipe_reqs(r : Recipe) -> bool:
	var ret : bool = true
	for mat in internal_inv.materials:
		var id = mat.type
		ret = ret and internal_inv.check_stock(id, r.melt_reqs[id], Statics.Material_states.LIQUID)
		ret = ret and internal_inv.check_stock(id, r.solid_reqs[id], Statics.Material_states.SOLID)
	return ret

func spend_recipe(r : Recipe):
	for mat in internal_inv.materials:
		var id = mat.type
		internal_inv.add_stock(id, -r.melt_reqs[id], Statics.Material_states.LIQUID)
		internal_inv.add_stock(id, -r.solid_reqs[id], Statics.Material_states.SOLID)

func _on_timer_timeout():
	if check_recipe_reqs(recipe):
		output.output_type = recipe.material
		output.generate(0, 1, Statics.Material_states.LIQUID)
		spend_recipe(recipe)


func _on_input_area_entered(area):
	if !placed:
		return
	
	var mat : MPMaterial = area.mat_data
	var liquid : bool = area.liquid
	
	if mat.type == Statics.Materials.CRYSTALS:
		liquid = area.inner_temp < 3

	input_resource(mat, liquid)
	area.destroy()
