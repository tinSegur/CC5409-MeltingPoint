extends Node2D

var sprite : Sprite2D
var timer : Timer
var player : Player
var player_position : Vector2
var ore_postition : Vector2
var ore : Statics.Materials

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().player
	sprite = $Sprite2D
	timer = $Timer
	timer.start()
	timer.timeout.connect(timer_ended)
	sprite.frame=ore

func _process(delta):
	player_position = player.get_player_tile_position()
	set_direction(player_position,ore_postition)

func set_direction(player_pos: Vector2, ore_pos: Vector2):
	var direction: Vector2 = player_pos.direction_to(ore_pos)
	sprite.rotation=direction.angle()+deg_to_rad(90)

func timer_ended():
	self.queue_free()
