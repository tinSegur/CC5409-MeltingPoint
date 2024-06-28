extends Machine


@export var efficiency : int = 3
var set_temp : int = 0
var output_mat : Statics.Materials = Statics.Materials.IRON
var gold_charge : int = 0
var is_charged : int = 0
var material_queue : Array = []
var orient : int = 0

@onready var sprite = $Sprite2D

func _ready():
	super._ready()
	output = $Stable_output

func _input_event(viewport, event, shape_idx):
	if event.is_action("mine") and placed:
		set_temp = (set_temp+1)%10
		sprite.set_frame_coords(Vector2i(set_temp, 2*is_charged + orient))

func input_resource(item : MPMaterial, liquid : bool) -> Statics.INPUT_CODES:
	Debug.sprint("input")
	
	material_queue.append(item)
	
	return Statics.INPUT_CODES.ACCEPT

func check_gold() -> bool:
	return gold_charge > 0


func spawn_resource():
	if gold_charge > 0:
		var mat = material_queue.pop_front()
		output.output_type = mat
		output.generate(0, 1)
		gold_charge -= 1
		if gold_charge == 0:
			is_charged = 0
			sprite.set_frame_coords(Vector2i(set_temp, 2*is_charged + orient))




func _on_area_2d_2_area_entered(area):
	var mat : MPMaterial = area.mat_data
	var liquid : bool = area.liquid
	area.queue_free()
	
	if (mat.type == Statics.Materials.GOLD and liquid):
		if (gold_charge == 0):
			is_charged = 1
			sprite.sprite.set_frame_coords(Vector2i(set_temp, 2*is_charged + orient))
		gold_charge += efficiency
		
