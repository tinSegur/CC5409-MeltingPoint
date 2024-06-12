extends Label
@onready var timer = $Timer
var fade: bool = false

func _ready():
	timer.timeout.connect(_fade)

func _physics_process(delta):
	position.y += -10*delta
	if fade:
		modulate = Color(modulate.r, modulate.g, modulate.b, modulate.a - 1 * delta)

func _fade():
	timer.timeout.disconnect(_fade)
	timer.timeout.connect(queue_free)
	fade = true
	timer.start(2)
