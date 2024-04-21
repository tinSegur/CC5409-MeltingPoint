class_name Machine
extends StaticBody2D

var placed = false
@export var builder_id: int = 0
@onready var hitbox = $Hitbox
@onready var resource_detector = $ResourceDetector
@onready var timer = $Timer
@onready var output = $Output


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if !placed:
		if builder_id == multiplayer.get_unique_id():
			var mouse_pos = Vector2i(get_global_mouse_position())
			var build_pos = Vector2i(mouse_pos.x - mouse_pos.x%18 + 9 * (1 if (sign(mouse_pos.x) == 0) else sign(mouse_pos.x)), 
									 mouse_pos.y - mouse_pos.y%18 + 2)
			send_pos.rpc_id(1, build_pos)
			
		if is_valid_place():
			modulate = Color(1,1,1,0.8)
		else:
			modulate = Color(1,0.1,0.1,0.8)

@rpc("call_local", "any_peer")
func place():
	placed = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	

func is_valid_place() -> bool:
	var bodies: Array = hitbox.get_overlapping_bodies()
	return ((bodies.size()-1) == 0)
	

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
