class_name TipButton
extends Button

signal mch_selected

var info : MPTip
var build_info: MPBuildInfo
var tip_display : VBoxContainer

func _ready():
	if is_instance_valid(info):
		text = info.name
	else:
		text = build_info.name
	pressed.connect(_on_pressed)

func setup(t_info : MPTip, container : VBoxContainer):
	info = t_info
	tip_display = container

func build_setup(b_info : MPBuildInfo, container : VBoxContainer):
	build_info = b_info
	tip_display = container

func _on_pressed():
	for child in tip_display.get_children():
		child.queue_free()
	if is_instance_valid(info):
		info.render_info(tip_display)
	else:
		build_info.render_info(tip_display)
