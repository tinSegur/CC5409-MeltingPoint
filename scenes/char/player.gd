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


@onready var camera = $Camera2D
@export var bullet_scene: PackedScene
@onready var pivot = $Pivot
@onready var mouse_area: Area2D = $MouseArea
@onready var mouse_area_col = $MouseArea/CollisionShape2D

@onready var mining_raycast: RayCast2D = $MiningRaycast
@onready var mine_timer = $MineTimer
var mining = false
var mining_radius = 60
var mining_coords : Vector2 = Vector2.ZERO
var mining_progress = 0
var tilemap: TileMap

@onready var build_menu = $CanvasLayer/BuildMenu
@onready var victory_screen = $CanvasLayer/VictoryScreen
var machine_container: Node2D
var build_scene: String
var build_preview: StaticBody2D
var building = false
var tile_selected = false
var building_tile = false
var tile_index = -1
var deleting = false
@onready var deleting_overlay = $CanvasLayer/DeletingOverlay

var inventory: Node

@onready var playback = $AnimationTree["parameters/playback"]

func _ready():
	machine_container = get_tree().current_scene.get_node("%Machines")
	inventory = get_tree().current_scene.get_node("Inventory")
	mine_timer.connect("timeout", _on_mine_timer_timeout)
	build_menu.machine_selected.connect(on_machine_selected)
	build_menu.tile_selected.connect(on_tile_selected)
	tilemap = get_tree().current_scene.get_node("TileMap")
	$AnimationTree.active = true
	victory_screen.hide()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("mine"):
			if tile_selected:
				mouse_area.monitoring = true
				mouse_area_col.shape.radius = 12
				building_tile = true
				return
			if deleting:
				var tile_coords = tilemap.get_tile_coords(get_global_mouse_position())
				if is_instance_valid(tilemap.get_cell_tile_data(0, tile_coords)):
					if tilemap.get_cell_source_id(0, tile_coords) > 3:
						tilemap.mine_tile.rpc(0, tilemap.get_tile_coords(get_global_mouse_position()))
						try_delete_items()
				else:
					try_delete_machine()
			if !building:
				mining = true
				if mining_raycast.is_colliding():
					var collision_point = mining_raycast.get_collision_point()
					var dir = Vector2.ZERO.direction_to(mining_raycast.target_position)
					mining_coords = tilemap.get_tile_coords(collision_point + dir)
					tilemap.breaking(mining_coords, 0)
					mine_timer.start(0.5)
			else:
				if is_instance_valid(build_preview):
					try_place_machine.rpc_id(1, build_preview.name)
				
		if event.is_action_released("mine"):
			if building_tile:
				mouse_area.monitoring = false
				mouse_area_col.shape.radius = 7
			building_tile = false
			if !building:
				mining = false
				mining_progress = 0
				if mining_raycast.is_colliding():
					tilemap.breaking(mining_coords, 0)
		
		if event.is_action_pressed("test"):
			test()
		
		if event.is_action_pressed("build"):
			mining = false
			build_menu.visible = !build_menu.visible
			if build_menu.visible:
				building_tile = false
				tile_selected = false
				deleting = false
				deleting_overlay.visible = false
				mouse_area.monitoring = false
				mouse_area_col.shape.radius = 7
				tile_index = -1
				tilemap.clear_previews()
				if is_instance_valid(build_preview):
					cancel_build.rpc_id(1, build_preview.name)
					building = false
					build_preview = null
		
		if event.is_action_pressed("cancel"):
			if building:
				building = false
				if is_instance_valid(build_preview):
					cancel_build.rpc_id(1, build_preview.name)
					build_preview = null
			mouse_area.monitoring = false
			mouse_area_col.shape.radius = 7
			building_tile = false
			tile_selected = false
			deleting = false
			deleting_overlay.visible = false
			tile_index = -1
			tilemap.clear_previews()
			if build_menu.visible:
				build_menu.visible = false
				
			
			if victory_screen.visible:
				victory_screen.hide()
		
		if event.is_action_pressed("next_tile"):
			if(tile_index >= 1):
				tile_index = tile_index%4 + 1
		
		if event.is_action_pressed("prev_tile"):
			if(tile_index >= 1):
				tile_index = (4 if tile_index == 1 else tile_index - 1)
				
		if event.is_action_pressed("delete"):
			deleting = !deleting
			if deleting:
				mouse_area.monitoring = true
				mouse_area_col.shape.radius = 7
				deleting_overlay.visible = true
				building = false
				building_tile = false
				tile_selected = false
				tile_index = -1
				tilemap.clear_previews()
			else:
				deleting_overlay.visible = false
				mouse_area.monitoring = false
				mouse_area_col.shape.radius = 7
		
		if event.is_action("Ability"):
			class_node.ability()

func _physics_process(delta: float) -> void:
	
	# Movement logic
	
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
		
		if mouse_area.monitoring:
			mouse_area.global_position = get_global_mouse_position()
		
	move_and_slide()
	
	# Mining logic
	
	if mining:
		if mining_raycast.is_colliding():
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
				tilemap.breaking(mining_coords, 0)
				mining_progress = 0
				mine_timer.stop()
	
	# Building logic
	
	if tile_selected:
		tilemap.show_preview(tilemap.get_tile_coords(get_global_mouse_position()), tile_index)
	
	if building_tile:
		if tile_index == 0:
			if (mouse_area.get_overlapping_bodies().size() == 0 and inventory.check_stock(Statics.Materials.IRON, 1)):
				if tilemap.place_tile(tilemap.get_tile_coords(get_global_mouse_position()), tile_index):
					manual_remove_resource.rpc_id(1, Statics.Materials.IRON, 1)
		else:
			if inventory.check_stock(Statics.Materials.IRON, 1):
				if tilemap.place_tile(tilemap.get_tile_coords(get_global_mouse_position()), tile_index):
					manual_remove_resource.rpc_id(1, Statics.Materials.IRON, 1)
	
	# Animation logic
	
	if (abs(velocity.x) > 0.1):
		playback.travel("walk")
	else:
		playback.travel("idle")

func victory():
	if is_multiplayer_authority():
		victory_screen.show()

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	
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
		tilemap.player = self

func _on_mine_timer_timeout():
	if mining:
		mining_progress += 1
		mine_timer.start(0.5)

func test():
	var tile_coords = tilemap.get_tile_coords(global_position)
	var tile: TileData = tilemap.get_cell_tile_data(3, tile_coords)
	if is_instance_valid(tile):
		Debug.sprint(tile.get_custom_data("temperature"))

func get_player_tile_position():
	Debug.sprint(tilemap.get_tile_coords(global_position))
	return tilemap.get_tile_coords(global_position)

@rpc
func send_data(pos : Vector2, vel : Vector2, pivot_scale: int):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	pivot.scale.x = pivot_scale

func on_machine_selected():
	spawn_machine.rpc_id(1, build_scene)
	building = true

func on_tile_selected():
	tile_selected = true

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
	
@rpc("call_local", "reliable")
func destroy_machine(m_name: String):
	var machine = machine_container.get_node(m_name)
	if machine.placed:
		machine.queue_free()

func mine_resource(resource: int):
	mining_progress = 0
	manual_add_resource.rpc_id(1, resource, 1)
	
@rpc("call_local", "reliable")
func manual_add_resource(resource: int, amount: int):
	inventory.add_stock(resource, amount)

@rpc("call_local", "reliable")
func manual_remove_resource(resource: int, amount: int):
	inventory.remove_stock(resource, amount)

func try_delete_machine():
	var bodies = mouse_area.get_overlapping_bodies()
	for body in bodies:
		var m = body as Machine
		if m:
			if m.name != "Hub":
				destroy_machine.rpc_id(1,m.name)
			return

func try_delete_items():
	var areas = mouse_area.get_overlapping_areas()
	for area in areas:
		var i = area as Item
		if i:
			i.destroy.rpc()
