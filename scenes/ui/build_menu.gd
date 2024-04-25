extends MarginContainer

var player: Player
@onready var miner_button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/MinerButton

signal machine_selected

func _ready():
	player = get_parent().get_parent()
	miner_button.pressed.connect(_miner_selected)
	

func _miner_selected():
	player.build_scene = "res://scenes/machines/miner.tscn"
	machine_selected.emit()
	visible = false
