class_name MachineButton
extends TextureButton

signal mch_selected

var machine_info : MPBuildInfo
var machine_preview : VBoxContainer
var player : Player

func _ready():
	texture_normal = machine_info.button
	texture_hover = machine_info.b_hover
	texture_pressed = machine_info.b_pressed
	

func setup(info : MPBuildInfo, preview : VBoxContainer, p : Player):
	machine_info = info
	machine_preview = preview
	player = p

func _on_mouse_entered():
	print("hover")
	machine_info.render_info(machine_preview)

func _on_pressed():
	print("pressed")
	if machine_info.machine_scene != null:
		player.build_scene = machine_info.machine_scene
		mch_selected.emit()
