class_name TipButton
extends Button

signal mch_selected

var info : MPTip
var tip_display : VBoxContainer

func _ready():
	text = info.name
	pressed.connect(_on_pressed)

func setup(t_info : MPTip, container : VBoxContainer):
	info = t_info
	tip_display = container

func _on_pressed():
	for child in tip_display.get_children():
		child.queue_free()
	info.render_info(tip_display)
