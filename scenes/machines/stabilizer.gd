extends Machine

@export var efficiency : int = 3
var set_temp : int = 0
var output_mat : Statics.Materials = Statics.Materials.IRON
var gold_charge : int = 0
var material_queue : Array = []

@onready var internal_inv : InternalInventory = $InternalInventory

func _ready():
	super._ready()
	output = $Stable_output

func input_resource(item : MPMaterial, liquid : bool) -> Statics.INPUT_CODES:
	Debug.sprint("input")
	
	material_queue.append(item)
	
	return Statics.INPUT_CODES.ACCEPT

func check_gold() -> bool:
	return internal_inv.check_stock(Statics.Materials.GOLD, 1, Statics.Material_states.LIQUID)


func spawn_resource():
	var mat = material_queue.pop_front()
	output.output_type = mat
	output.generate(0, 1)




func _on_area_2d_2_area_entered(area):
	var mat : MPMaterial = area.mat_data
	var liquid : bool = area.liquid
	area.queue_free()
	
	if (mat.type == Statics.Materials.GOLD and liquid):
		gold_charge += efficiency
