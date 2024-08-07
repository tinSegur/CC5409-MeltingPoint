extends MarginContainer

@export var player_tips : Array[MPTip]
@export var map_tips : Array[MPTip]
@export var machine_tips : Array[MPBuildInfo]
@export var tip_button : PackedScene
@onready var tips_container = %TipsContainer
@onready var tip_display = %TipDisplay
@onready var back = %Back

var previous_menu: Control

func _ready():
	for tip in player_tips:
		var btn : TipButton = tip_button.instantiate()
		btn.setup(tip, tip_display)
		tips_container.add_child(btn)
	
	for tip in map_tips:
		var btn : TipButton = tip_button.instantiate()
		btn.setup(tip, tip_display)
		tips_container.add_child(btn)
	
	for tip in machine_tips:
		var btn : TipButton = tip_button.instantiate()
		btn.build_setup(tip, tip_display)
		tips_container.add_child(btn)
	
	back.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	visible = false
	if is_instance_valid(previous_menu):
		previous_menu.visible = true
