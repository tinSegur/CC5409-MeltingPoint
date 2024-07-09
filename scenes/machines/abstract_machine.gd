class_name Machine
extends StaticBody2D

@export var output_type : MPMaterial
@export var offset_vec : Vector2 = Vector2(9, 2)
@export var info: MPBuildInfo

var placed = false
var overclocked = false
@export var rotable = true
@export var flippable = false
@export var builder_id: int = 0
@onready var hitbox = $Hitbox
@onready var timer : Timer = $Timer
@onready var output : Output = $Output

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if !placed:
		if builder_id == multiplayer.get_unique_id():
			var mouse_pos = Vector2i(get_global_mouse_position())
			var snap = mouse_pos.snapped(Vector2i(18, 18))
			#var build_pos = Vector2i(mouse_pos.x - mouse_pos.x%18 + offset_vec.x, #* (1 if (sign(mouse_pos.x) == 0) else sign(mouse_pos.x)), 
			#						 mouse_pos.y - mouse_pos.y%18 + offset_vec.y)
			var build_pos = Vector2i(snap.x + offset_vec.x, 
										snap.y + offset_vec.y)
			send_pos.rpc_id(1, build_pos)
			
		if is_valid_place():
			modulate = Color(1,1,1,0.8)
		else:
			modulate = Color(1,0.1,0.1,0.8)

func _input(event):
	if !placed and builder_id == multiplayer.get_unique_id():
		if event.is_action("next_tile"):
			if rotable:
				mouse_rotate.rpc(true)
			elif flippable:
				scale.x = -1
		elif event.is_action("prev_tile"):
			if rotable:
				mouse_rotate.rpc(false)
			elif flippable:
				scale.x = 1 


@rpc("call_local", "any_peer")
func place():
	placed = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	

func is_valid_place() -> bool:
	var bodies: Array = hitbox.get_overlapping_bodies()
	return ((bodies.size()-1) == 0)

func input_resource(item : MPMaterial, liquid: bool) -> Statics.INPUT_CODES:
	return Statics.INPUT_CODES.NOTACCEPT


func try_place() -> bool:
	if is_valid_place():
		place.rpc()
		return true
	return false

func cancel_build():
	queue_free()

@rpc("call_local", "any_peer")
func send_pos(pos: Vector2):
	global_position = pos

@rpc("call_local", "any_peer", "reliable")
func mouse_rotate(bb : bool):
		if is_multiplayer_authority():
			if bb:
				rotate(deg_to_rad(45))
				offset_vec = offset_vec.rotated(deg_to_rad(45))
			else:
				rotate(deg_to_rad(-45))
				offset_vec = offset_vec.rotated(deg_to_rad(-45))
		

