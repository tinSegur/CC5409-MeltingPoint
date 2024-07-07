class_name UILobbyPlayer
extends MarginContainer

@onready var player_name: Label = %Name
@onready var player_role: Label = %Role
@onready var ready_texture: TextureRect = %Ready
@onready var icon_texture = %Icon

@export var default_icon: Texture2D
@export var engineer_icon: Texture2D
@export var scientist_icon: Texture2D
@export var scout_icon: Texture2D

var player_id: int


func _ready() -> void:
	player_role.hide()
	ready_texture.hide()


func setup(player: Statics.PlayerData) -> void:
	player_id = player.id
	name = str(player_id)
	_update(player)
	Game.player_updated.connect(_on_player_updated)


func _on_player_updated(id: int) -> void:
	if id == player_id:
		_update(Game.get_player(player_id))


func _update(player: Statics.PlayerData):
	_set_player_name(player.name)
	_set_player_role(player.role)


func _set_player_name(value: String) -> void:
	player_name.text = value


func _set_player_role(value: Statics.Role) -> void:
	player_role.visible = value != Statics.Role.NONE
	icon_texture.visible = value != Statics.Role.NONE
	match value:
		Statics.Role.SCOUT:
			player_role.text = "Scout"
			icon_texture.set_texture(scout_icon)
		Statics.Role.SCIENTIST:
			player_role.text = "Scientist"
			icon_texture.set_texture(scientist_icon)
		Statics.Role.ENGINEER:
			player_role.text = "Engineer"
			icon_texture.set_texture(engineer_icon)


func set_ready(value: bool) -> void:
	ready_texture.visible = value
