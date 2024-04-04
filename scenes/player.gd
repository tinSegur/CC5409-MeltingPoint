class_name Player
extends CharacterBody2D

var gravity = 98
var jump_speed = 80
var speed = 60
var acceleration = 60


@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera = $Camera2D
@onready var mining_raycast: RayCast2D = $MiningRaycast
@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.sprint("Player %s score %d" % [name, score])

var mining = false
var mining_radius = 400
var can_mine = true
@onready var mine_timer = $MineTimer

func _ready():
	mine_timer.connect("timeout", _on_mine_timer_timeout)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("mine"):
			mining = true
		if event.is_action_released("mine"):
			mining = false
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
		if Input.is_action_just_pressed("jump") && is_on_floor():
			velocity.y = -jump_speed
		
		var move_input = Input.get_axis("move_left", "move_right")
		velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
		send_data.rpc(global_position, velocity)
		
		var mouse_dir = to_local(get_global_mouse_position())
		mining_raycast.target_position = mining_radius * Vector2.ZERO.direction_to(mouse_dir)
		
	move_and_slide()
	
	if mining:
		if can_mine and mining_raycast.is_colliding():
			var tilemap = mining_raycast.get_collider()
			if tilemap.is_class("TileMap"):
				var collision_point = mining_raycast.get_collision_point()
				var dir = Vector2.ZERO.direction_to(mining_raycast.target_position)
				tilemap.mine(collision_point + dir)
				can_mine = false
				mine_timer.start()



func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	if is_multiplayer_authority():
		camera.enabled = true

func _on_mine_timer_timeout():
	can_mine = true

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
