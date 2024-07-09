extends Machine

@export var efficiency : int = 3
@export var temp : int = 0
@export var gold_charge : int = 0
@export var is_charged : int = 0
var output_mat : Statics.Materials = Statics.Materials.IRON
var material_queue : Array = []
var orient : int = 0

@onready var sprite = $Sprite2D


func _ready():
	super._ready()
	output.stable_mode = true

func _input(event):
	if !placed and builder_id == multiplayer.get_unique_id():
		if event.is_action("next_tile"):
			if rotable:
				mouse_rotate.rpc(true)
			elif flippable:
				scale.x = -1
				sprite.scale.x = -1
				orient = 1
				update_sprite()
		elif event.is_action("prev_tile"):
			if rotable:
				mouse_rotate.rpc(false)
			elif flippable:
				scale.x = 1
				sprite.scale.x = 1
				orient = 0
				update_sprite()

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mine") and placed:
		temp = (temp+1)%10
		set_temp.rpc(temp)


func place():
	super.place()
	timer.start()

func input_resource(item : MPMaterial, liquid : bool) -> Statics.INPUT_CODES:
	#Debug.sprint("input")
	
	material_queue.append(item)
	
	return Statics.INPUT_CODES.ACCEPT

func spawn_resource():
	if material_queue.is_empty():
		return
	#Debug.sprint("stabilizer spawn")
	#Debug.sprint(gold_charge)
	if gold_charge > 0:
		var mat = material_queue.pop_front()
		output.output_type = mat
		output.output_temp = temp
		#Debug.sprint("mat")
		output.generate(0, 1)
		gold_charge -= 1
		if gold_charge == 0:
			is_charged = 0
		set_charge(gold_charge)

func _on_area_2d_2_area_entered(area):
	if !placed:
		return
	
	var mat : MPMaterial = area.mat_data
	var liquid : bool = area.liquid
	area.destroy()
	
	if (mat.type == Statics.Materials.GOLD and liquid):
		if (gold_charge == 0):
			is_charged = 1
		
		gold_charge += efficiency
		set_charge.rpc(gold_charge)
		

func update_sprite():
	sprite.set_frame_coords(Vector2i(temp, 2*is_charged + orient))
	print(Vector2i(temp, 2*is_charged + orient))


@rpc("call_remote")
func set_charge(amount : int):
	gold_charge = amount
	is_charged = 1 if amount > 0 else 0
	update_sprite()

@rpc("call_local", "any_peer")
func set_temp(amount : int):
	temp = amount
	update_sprite()


