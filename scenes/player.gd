class_name Player
extends CharacterBody2D

var gravity = 9.8
var jump_speed = 0.2
var speed = 0.15
var acceleration = 0.1

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer


@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.sprint("Player %s score %d" % [name, score])


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc(Game.get_current_player().name)
			var bullet = bullet_scene.instantiate()
			# spawner will spawn a bullet on every simulated
			multiplayer_spawner.add_child(bullet, true)
			# triggers syncronizer
			score += 1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("jump"):
			test.rpc("jump!")
			velocity.y = -jump_speed
		
		var move_input = Input.get_axis("move_left", "move_right")
		velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
		#send_data.rpc(global_position, velocity)
	move_and_slide()



func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.sprint(message)
	Debug.sprint(sender_player.name)

@rpc
func send_data(pos : Vector2, vel : Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
