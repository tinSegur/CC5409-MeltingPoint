extends Node2D

var sprite : Sprite2D
var timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Sprite2D
	timer = $Timer
	timer.start()
	timer.timeout.connect(timer_ended())

func timer_ended():
	self.queue_free()
