extends MarginContainer

var player: Player
@onready var miner_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/MinerButton
@onready var platform_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PlatformButton
@onready var pipe_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PipeButton
@onready var ext_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/OutputButton
@onready var pump_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/PumpButton
@onready var cutter_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/CutterButton
@onready var ad_miner_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/AdMinerButton
@onready var stabilizer_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/StabilizerButton
@onready var ramp_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/RampButton
@onready var ladder_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/LadderButton
@onready var wa_platform_button = $PanelContainer/MarginContainer/HBoxContainer/MachineSelector/GridContainer/WaPlatformButton

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
	
	pump_button.pressed.connect(_pump_selected)
	pump_button.mouse_entered.connect(_pump_hover)
	
	cutter_button.pressed.connect(_cutter_selected)
	cutter_button.mouse_entered.connect(_cutter_hover)
	
	ad_miner_button.pressed.connect(_ad_miner_selected)
	ad_miner_button.mouse_entered.connect(_ad_miner_hover)
	
	stabilizer_button.pressed.connect(_stabilizer_selected)
	stabilizer_button.mouse_entered.connect(_stabilizer_hover)
	
	ramp_button.pressed.connect(_ramp_selected)
	ramp_button.mouse_entered.connect(_ramp_hover)
	
	ladder_button.pressed.connect(_ladder_selected)
	ladder_button.mouse_entered.connect(_ladder_hover)
	
	wa_platform_button.pressed.connect(_wa_platform_selected)
	wa_platform_button.mouse_entered.connect(_wa_platform_hover)
	
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

func _pump_hover():
	build_info = load("res://resources/build_info/pump_info.tres")
	build_info.render_info(machine_preview)

func _pump_selected():
	#player.build_scene = "res://scenes/machines/pump.tscn"
	#machine_selected.emit()
	#visible = false
	pass
	
func _cutter_hover():
	build_info = load("res://resources/build_info/cutter_info.tres")
	build_info.render_info(machine_preview)

func _cutter_selected():
	#player.build_scene = "res://scenes/machines/cutter.tscn"
	#machine_selected.emit()
	#visible = false
	pass

func _ad_miner_hover():
	build_info = load("res://resources/build_info/ad_miner_info.tres")
	build_info.render_info(machine_preview)

func _ad_miner_selected():
	#player.build_scene = "res://scenes/machines/advanced_miner.tscn"
	#machine_selected.emit()
	#visible = false
	pass

func _stabilizer_hover():
	build_info = load("res://resources/build_info/stabilizer_info.tres")
	build_info.render_info(machine_preview)

func _stabilizer_selected():
	#player.build_scene = "res://scenes/machines/stabilizer.tscn"
	#machine_selected.emit()
	#visible = false
	pass

func _ramp_hover():
	build_info = load("res://resources/build_info/ramp_info.tres")
	build_info.render_info(machine_preview)

func _ramp_selected():
	#player.tile_index = 0
	#tile_selected.emit()
	#visible = false
	pass

func _ladder_hover():
	build_info = load("res://resources/build_info/ladder_info.tres")
	build_info.render_info(machine_preview)

func _ladder_selected():
	#player.tile_index = 0
	#tile_selected.emit()
	#visible = false
	pass

func _wa_platform_hover():
	build_info = load("res://resources/build_info/wa_platform_info.tres")
	build_info.render_info(machine_preview)

func _wa_platform_selected():
	#player.tile_index = 0
	#tile_selected.emit()
	#visible = false
	pass
