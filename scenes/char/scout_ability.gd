extends Node2D

var sprite : Sprite2D
var timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Sprite2D
	timer = $Timer
	timer.start()
	timer.timeout.connect(timer_ended)
	
func set_direction(player_pos: Vector2, ore_pos: Vector2):
	#apuntar el sprite en direccion al ore con un offset del personaje
	var direction: Vector2 = ore_pos - player_pos
	direction.normalized()
	sprite.rotation+=direction.angle()

func timer_ended():
	self.queue_free()
