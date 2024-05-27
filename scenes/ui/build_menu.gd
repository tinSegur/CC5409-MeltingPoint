extends MarginContainer

var player: Player
@onready var miner_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/MinerButton
@onready var platform_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PlatformButton
@onready var pipe_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PipeButton
@onready var ext_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/TextureButton2

signal machine_selected
signal tile_selected

func _ready():
	player = get_parent().get_parent()
	miner_button.pressed.connect(_miner_selected)
	platform_button.pressed.connect(_platform_selected)
	pipe_button.pressed.connect(_pipe_selected)
	ext_button.pressed.connect(_extractor_selected)
	

func _miner_selected():
	player.build_scene = "res://scenes/machines/miner.tscn"
	machine_selected.emit()
	visible = false

func _platform_selected():
	player.tile_index = 0
	tile_selected.emit()
	visible = false

func _pipe_selected():
	player.tile_index = 1
	tile_selected.emit()
	visible = false

func _extractor_selected():
	player.build_scene = "res://scenes/machines/hub_output.tscn"
	machine_selected.emit()
	visible = false
