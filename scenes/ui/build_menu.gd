extends MarginContainer

var player: Player
@onready var miner_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/MinerButton
@onready var platform_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PlatformButton
@onready var pipe_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PipeButton
@onready var ext_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/OutputButton
@onready var machine_preview = $PanelContainer/MarginContainer/HBoxContainer/MachinePreview
@onready var buttons_container = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer

var build_info : MPBuildInfo

signal machine_selected
signal tile_selected

func _ready():
	player = get_parent().get_parent()
	
	miner_button.pressed.connect(_miner_selected)
	miner_button.mouse_entered.connect(_miner_hover)
	
	platform_button.pressed.connect(_platform_selected)
	platform_button.mouse_entered.connect(_platform_hover)
	
	pipe_button.pressed.connect(_pipe_selected)
	pipe_button.mouse_entered.connect(_pipe_hover)
	
	ext_button.pressed.connect(_extractor_selected)
	ext_button.mouse_entered.connect(_extractor_hover)
	
	for button in buttons_container.get_children():
		button.mouse_exited.connect(_clear_info)
	

func _clear_info():
	for node in machine_preview.get_children():
		node.queue_free()

func _miner_hover():
	build_info = load("res://resources/build_info/miner_info.tres")
	build_info.render_info(machine_preview)

func _miner_selected():
	player.build_scene = "res://scenes/machines/miner.tscn"
	
	machine_selected.emit()
	visible = false

func _platform_hover():
	build_info = load("res://resources/build_info/platform_info.tres")
	build_info.render_info(machine_preview)

func _platform_selected():
	player.tile_index = 0
	tile_selected.emit()
	visible = false

func _pipe_hover():
	build_info = load("res://resources/build_info/pipe_info.tres")
	build_info.render_info(machine_preview)

func _pipe_selected():
	player.tile_index = 1
	tile_selected.emit()
	visible = false

func _extractor_hover():
	build_info = load("res://resources/build_info/extractor_info.tres")
	build_info.render_info(machine_preview)

func _extractor_selected():
	player.build_scene = "res://scenes/machines/hub_output.tscn"
	machine_selected.emit()
	visible = false
