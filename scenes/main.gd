extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var tile_map = $TileMap

func _ready() -> void:
	for player_data in Game.players:
		var player = player_scene.instantiate()
		
		players.add_child(player)
		player.setup(player_data)
		
