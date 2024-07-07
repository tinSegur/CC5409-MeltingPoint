extends Machine

var radius = 63
@onready var machine_detector : Area2D = $MachineDetector
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

signal overclock_placed()

func _ready():
	animated_sprite.stop()

func _physics_process(delta):
	super._physics_process(delta)

func is_valid_place():
	return super.is_valid_place()

func place():
	super.place()
	animated_sprite.play()
	
	var bodies = machine_detector.get_overlapping_bodies()
	for machine in bodies:
		overclock_machine(machine)
	
	overclock_placed.emit()

func cancel_build():
	Debug.sprint("overclock cancel")
	if placed:
		var bodies = machine_detector.get_overlapping_bodies()
		for machine in bodies:
			unoverclock_machine(machine)
	queue_free()

func overclock_machine(machine : Machine):
	var hub = machine as Hub
	if is_instance_valid(hub):
		return
	
	if machine == self:
		return
	
	if machine.placed:
		machine.modulate = Color(0.9, 0.7, 1.0, 1.0)
		if placed:
			machine.timer.wait_time = machine.timer.wait_time/2

func unoverclock_machine(machine : Machine):
	var hub = machine as Hub
	if is_instance_valid(hub):
		return
		
	if machine == self:
		return
	
	if machine.placed:
		machine.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if placed:
			machine.timer.wait_time = machine.timer.wait_time*2

func _on_machine_detector_body_entered(body):
	overclock_machine(body)

func _on_machine_detector_body_exited(body):
	unoverclock_machine(body)
