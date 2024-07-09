extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var x_limits: Vector2
@export var y_limits_iron: Vector2
@export var y_limits_gold: Vector2
@export var y_limits_crystal: Vector2
@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var tile_map = $TileMap
@onready var inventory = $Inventory
var players_ready = 0
var variety = 0
var victory_happened = false
var iron_positions : Array[Vector2]
var gold_positions : Array[Vector2]
var crystal_positions : Array[Vector2]

var ore_forms = [[Vector2(0,0),Vector2(-1,0),Vector2(1,0),Vector2(1,1)],
				 [Vector2(0,0),Vector2(-1,0),Vector2(-1,-1),Vector2(1,0),Vector2(0,1)],
				 [Vector2(-1,-1),Vector2(0,0),Vector2(1,-1)],
				 [Vector2(0,0),Vector2(-1,0),Vector2(1,0),Vector2(0,-1)],
				 [Vector2(0,0),Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1)],
				]

func _ready() -> void:
	for player_data in Game.players:
		var player = player_scene.instantiate()
		player.global_position = Vector2(1350, 614)
		players.add_child(player)
		player.setup(player_data)
	player_ready.rpc_id(1)

func _input(event):
	if event.is_action_pressed("1"):
		inventory.add_resource.rpc(Statics.Materials.IRON, 10, Statics.Material_states.SOLID)
	if event.is_action_pressed("2"):
		inventory.add_resource.rpc(Statics.Materials.IRON, 10, Statics.Material_states.LIQUID)
	if event.is_action_pressed("3"):
		inventory.add_resource.rpc(Statics.Materials.GOLD, 10, Statics.Material_states.SOLID)
	if event.is_action_pressed("4"):
		inventory.add_resource.rpc(Statics.Materials.GOLD, 10, Statics.Material_states.LIQUID)
	if event.is_action_pressed("5"):
		inventory.add_resource.rpc(Statics.Materials.ADVANCED, 10, Statics.Material_states.SOLID)
	if event.is_action_pressed("6"):
		inventory.add_resource.rpc(Statics.Materials.ADVANCED, 10, Statics.Material_states.LIQUID)
	if event.is_action_pressed("7"):
		inventory.add_resource.rpc(Statics.Materials.CRYSTALS, 10, Statics.Material_states.SOLID)
	if event.is_action_pressed("8"):
		inventory.add_resource.rpc(Statics.Materials.CRYSTALS, 10, Statics.Material_states.LIQUID)

@rpc("call_local", "any_peer")
func player_ready():
	players_ready += 1
	if players_ready == Game.players.size():
		resource_generation()

func resource_generation():
	if is_multiplayer_authority():
		var rng = RandomNumberGenerator.new()
		var _used_positions = [Vector2(-1,-1)]
		# Iron
		var N_resources = Game.iron_amount
		while N_resources!=0:
			var x = Vector2(-1,-1)
			var pure_prob: float = 1.0
			while _used_positions.has(x):
				x = Vector2(rng.randi_range(x_limits[0],x_limits[1]),rng.randi_range(Game.iron_min,Game.iron_max))
			if !is_instance_valid(tile_map.get_cell_tile_data(0, x)):
				continue
			_used_positions.append(x)
			var form = ore_forms[rng.randi_range(0, ore_forms.size()-1)]
			for pos in form:
				tile_map.generate_resource.rpc("Iron", x + pos, rng.randf() <= pure_prob)
				pure_prob *= 0.7
			send_used_positions.rpc(x,Statics.Materials.IRON)
			N_resources-=1
		# Gold
		N_resources = Game.gold_amount
		while N_resources!=0:
			var x = Vector2(-1,-1)
			var pure_prob: float = 1.0
			while _used_positions.has(x):
				x = Vector2(rng.randi_range(x_limits[0],x_limits[1]),rng.randi_range(Game.gold_min,Game.gold_max))
			if !is_instance_valid(tile_map.get_cell_tile_data(0, x)):
				continue
			_used_positions.append(x)
			var form = ore_forms[rng.randi_range(0, ore_forms.size()-1)]
			for pos in form:
				tile_map.generate_resource.rpc("Gold",x + pos, rng.randf() <= pure_prob)
				pure_prob *= 0.7
			send_used_positions.rpc(x,Statics.Materials.GOLD)
			N_resources-=1
		# Crystal
		N_resources = Game.crystal_amount
		while N_resources!=0:
			var x = Vector2(-1,-1)
			var pure_prob: float = 1.0
			while _used_positions.has(x):
				x = Vector2(rng.randi_range(x_limits[0],x_limits[1]),rng.randi_range(Game.crystal_min,Game.crystal_max))
			if !is_instance_valid(tile_map.get_cell_tile_data(0, x)):
				continue
			_used_positions.append(x)
			var form = ore_forms[rng.randi_range(0, ore_forms.size()-1)]
			for pos in form:
				tile_map.generate_resource.rpc("Crystal",x + pos, rng.randf() <= pure_prob)
				pure_prob *= 0.7
			send_used_positions.rpc(x,Statics.Materials.CRYSTALS)
			N_resources-=1

func get_used_positions():
	return [iron_positions,gold_positions,crystal_positions]

@rpc("authority", "call_local", "reliable")
func send_used_positions(positions: Vector2, ore : Statics.Materials):
	match ore:
		Statics.Materials.IRON: 
			iron_positions.append(positions)
		Statics.Materials.GOLD: 
			gold_positions.append(positions)
		Statics.Materials.CRYSTALS: 
			crystal_positions.append(positions)

func _on_inventory_stock_variety(d):
	if d:
		variety += 1
	else:
		variety -= 1
	
	if variety == 8 and !victory_happened:
		for player in players.get_children():
			player.victory()
		victory_happened = true
