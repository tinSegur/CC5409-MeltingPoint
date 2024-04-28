extends MarginContainer

var player: Player
@onready var miner_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/MinerButton
@onready var platform_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PlatformButton

signal machine_selected
signal tile_selected

func _ready():
	player = get_parent().get_parent()
	miner_button.pressed.connect(_miner_selected)
	platform_button.pressed.connect(_platform_selected)
	

func _miner_selected():
	player.build_scene = "res://scenes/machines/miner.tscn"
	machine_selected.emit()
	visible = false

func _platform_selected():
	#player.build_scene = "res://scenes/machines/miner.tscn"
	tile_selected.emit()
	visible = false
