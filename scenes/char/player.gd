class_name Player
extends CharacterBody2D

var gravity = 98
var jump_speed = 80
var speed = 60
var acceleration = 60
var class_enum = Statics.Role

var class_node

var class_scene_dict = {
	class_enum.ENGINEER : preload("res://scenes/char/engineer_node.tscn"),
	class_enum.SCIENTIST : preload("res://scenes/char/scientist_node.tscn"),
	class_enum.SCOUT : preload("res://scenes/char/scout_node.tscn")	
}


@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera = $Camera2D
@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.sprint("Player %s score %d" % [name, score])

@onready var mining_raycast: RayCast2D = $MiningRaycast
@onready var mine_timer = $MineTimer
var mining = false
var mining_radius = 400
var mining_coords : Vector2 = Vector2.ZERO
var mining_progress = 0

func _ready():
	mine_timer.connect("timeout", _on_mine_timer_timeout)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("mine"):
			mining = true
			if mining_raycast.is_colliding():
				var tilemap = mining_raycast.get_collider()
				var collision_point = mining_raycast.get_collision_point()
				var dir = Vector2.ZERO.direction_to(mining_raycast.target_position)
				mining_coords = tilemap.get_tile_coords(collision_point + dir)
				tilemap.breaking(mining_coords, 0)
				mine_timer.start(0.5)
		if event.is_action_released("mine"):
			mining = false
			mining_progress = 0
			if mining_raycast.is_colliding():
				var tilemap = mining_raycast.get_collider()
				tilemap.breaking(mining_coords, 0)
		if event.is_action_pressed("test"):
			test()

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
		if mining_raycast.is_colliding():
			var tilemap = mining_raycast.get_collider()
			var collision_point = mining_raycast.get_collision_point()
			var dir = Vector2.ZERO.direction_to(mining_raycast.target_position)
			var tile_coords = tilemap.get_tile_coords(collision_point + dir)
			if(tile_coords == mining_coords):
				tilemap.breaking(mining_coords, mining_progress)
				if mine_timer.is_stopped():
					mine_timer.start(0.5)
			else:
				tilemap.breaking(mining_coords, 0)
				mining_coords = tile_coords
				mining_progress = 0
				mine_timer.start(0.5)
		else:
			if mining_progress > 0:
				var tilemap = get_tree().current_scene.find_child("TileMap")
				tilemap.breaking(mining_coords, 0)
				mining_progress = 0
				mine_timer.stop()

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	
	class_node = class_scene_dict[player_data.role].instantiate()
	add_child(class_node)
	
	$Sprite2D.set_texture(class_node.get_player_sprite())
	
	if is_multiplayer_authority():
		camera.enabled = true

func _on_mine_timer_timeout():
	if mining:
		mining_progress += 1
		mine_timer.start(0.5)

func test():
	var tilemap = get_tree().current_scene.find_child("TileMap")
	var tile_coords = tilemap.get_tile_coords(global_position)
	var tile: TileData = tilemap.get_cell_tile_data(2, tile_coords)
	if is_instance_valid(tile):
		Debug.sprint(tile.get_custom_data("temperature"))

@rpc
func send_data(pos : Vector2, vel : Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
