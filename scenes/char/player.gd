class_name Player
extends CharacterBody2D


var gravity = 200
var jump_speed = 135
var speed = 85
var acceleration = 200
var mine_time = 0.5

var class_enum = Statics.Role

var class_node

var class_scene_dict = {
	class_enum.ENGINEER : preload("res://scenes/char/engineer_node.tscn"),
	class_enum.SCIENTIST : preload("res://scenes/char/scientist_node.tscn"),
	class_enum.SCOUT : preload("res://scenes/char/scout_node.tscn")
}

var stat_dict = {
	"gravity" : 98,
	"jump_speed" : 80,
	"speed" : 60,
	"acceleration" : 60,
	"mine_time" : 0.5,
	"mining_radius" : 60
}


@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera = $Camera2D
@export var bullet_scene: PackedScene
@onready var pivot = $Pivot

@export var score = 1 :
	set(value):
		score = value
		Debug.sprint("Player %s score %d" % [name, score])

@onready var mining_raycast: RayCast2D = $MiningRaycast
@onready var mine_timer = $MineTimer
var mining = false
var mining_radius = 60
var mining_coords : Vector2 = Vector2.ZERO
var mining_progress = 0

var machine_container: Node2D
var build_scene: String
var build_preview: StaticBody2D
var building = false

func _ready():
	machine_container = get_tree().current_scene.get_node("%Machines")
	mine_timer.connect("timeout", _on_mine_timer_timeout)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("mine"):
			if !building:
				mining = true
				if mining_raycast.is_colliding():
					var tilemap = mining_raycast.get_collider()
					var collision_point = mining_raycast.get_collision_point()
					var dir = Vector2.ZERO.direction_to(mining_raycast.target_position)
					mining_coords = tilemap.get_tile_coords(collision_point + dir)
					tilemap.breaking(mining_coords, 0)
					mine_timer.start(0.5)
			else:
				if is_instance_valid(build_preview):
					try_place_machine.rpc_id(1, build_preview.name)
				
		if event.is_action_released("mine"):
			if !building:
				mining = false
				mining_progress = 0
				if mining_raycast.is_colliding():
					var tilemap = mining_raycast.get_collider()
					tilemap.breaking(mining_coords, 0)
		
		if event.is_action_pressed("test"):
			test()
		
		if event.is_action_pressed("build"):
			mining = false
			building = !building
			if building:
				build_scene = "res://scenes/machines/miner.tscn"
				spawn_machine.rpc_id(1, build_scene)
			else:
				cancel_build.rpc_id(1, build_preview.name)
				building = false
				build_preview = null
		
		if event.is_action_pressed("cancel"):
			if building:
				cancel_build.rpc_id(1, build_preview.name)
				building = false
				build_preview = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("jump") && is_on_floor():
			velocity.y = -jump_speed
		
		var move_input = Input.get_axis("move_left", "move_right")

		velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
		
		if move_input != 0:
			pivot.scale.x = -sign(move_input)
		
		send_data.rpc(global_position, velocity, pivot.scale.x)

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
					mine_timer.start(mine_time)
			else:
				tilemap.breaking(mining_coords, 0)
				mining_coords = tile_coords
				mining_progress = 0
				mine_timer.start(mine_time)
		else:
			if mining_progress > 0:
				var tilemap = get_tree().current_scene.find_child("TileMap")
				tilemap.breaking(mining_coords, 0)
				mining_progress = 0
				mine_timer.stop()
				
	#if building:
		#if is_instance_valid(build_preview):
			#var mouse_pos = Vector2i(get_global_mouse_position())
			#var build_pos = Vector2i(mouse_pos.x - mouse_pos.x%18 + 9 * sign(mouse_pos.x), 
									 #mouse_pos.y - mouse_pos.y%18 + 2)
			#build_preview.global_position = build_pos

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	
	class_node = class_scene_dict[player_data.role].instantiate()
	add_child(class_node)
	
	$Pivot/Sprite2D.set_texture(class_node.get_player_sprite())
	
	stat_dict = class_node.get_stats()
	
	gravity = stat_dict.gravity
	jump_speed = stat_dict.jump_speed
	speed = stat_dict.speed
	acceleration = stat_dict.acceleration
	mine_time = stat_dict.mine_time
	mining_radius = stat_dict.mining_radius
	
	
	if is_multiplayer_authority():
		camera.enabled = true

func _on_mine_timer_timeout():
	if mining:
		mining_progress += 1
		mine_timer.start(0.5)

func test():
	var tilemap = get_tree().current_scene.find_child("TileMap")
	var tile_coords = tilemap.get_tile_coords(global_position)
	var tile: TileData = tilemap.get_cell_tile_data(3, tile_coords)
	if is_instance_valid(tile):
		Debug.sprint(tile.get_custom_data("temperature"))

@rpc
func send_data(pos : Vector2, vel : Vector2, pivot_scale: int):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	pivot.scale.x = pivot_scale

@rpc("call_local", "reliable")
func spawn_machine(machine_scene: String):
	var mouse_pos = get_global_mouse_position()
	var machine = load(machine_scene).instantiate()
	machine.global_position = mouse_pos
	machine.builder_id = multiplayer.get_remote_sender_id()
	machine_container.add_child(machine, true)
	recieve_machine_name.rpc_id(multiplayer.get_remote_sender_id(), machine.name)

@rpc("call_local", "any_peer", "reliable")
func recieve_machine_name(m_name: String):
	build_preview = machine_container.get_node(m_name)

@rpc("call_local", "reliable")
func try_place_machine(m_name: String):
	var machine = machine_container.get_node(m_name)
	
	# Costo placeholder
	var inventory = get_tree().current_scene.get_node("Inventory")
	if inventory.check_stock(Statics.Materials.IRON, 5):
		if machine.try_place():
			inventory.remove_stock(Statics.Materials.IRON, 5)
			place_success.rpc_id(multiplayer.get_remote_sender_id())

@rpc("call_local", "any_peer", "reliable")
func place_success():
	building = false
	build_preview = null
	
@rpc("call_local", "reliable")
func cancel_build(m_name: String):
	var machine = machine_container.get_node(m_name)
	machine.queue_free()
