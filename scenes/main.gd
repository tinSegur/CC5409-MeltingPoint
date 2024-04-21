extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var x_limits: Vector2
@export var y_limits: Vector2
@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var tile_map = $TileMap
var players_ready = 0

func _ready() -> void:
	for player_data in Game.players:
		var player = player_scene.instantiate()
		
		players.add_child(player)
		player.setup(player_data)
	player_ready.rpc_id(1)

@rpc("call_local", "any_peer")
func player_ready():
	players_ready += 1
	if players_ready == Game.players.size():
		resource_generation()

func resource_generation():
	if is_multiplayer_authority():
		var rng = RandomNumberGenerator.new()
		var N_resources = 5
		var used_positions = [Vector2(-1,-1)]
		while N_resources!=0:
			var x = Vector2(-1,-1)
			while used_positions.has(x):
				x = Vector2(rng.randi_range(x_limits[0],x_limits[1]),rng.randi_range(y_limits[0],y_limits[1]))
#				x = Vector2(rng.randi_range(-4,28),rng.randi_range(8,9))
			used_positions.append(x)
			tile_map.generate_resource.rpc("Iron",x)
			N_resources-=1
