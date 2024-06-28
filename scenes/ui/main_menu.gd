extends Control

@onready var play_button = $VBoxContainer/NinePatchRect/VBoxContainer/PlayButton
@onready var help_button = $VBoxContainer/NinePatchRect/VBoxContainer/HelpButton
@onready var credits_button = $VBoxContainer/NinePatchRect/VBoxContainer/CreditsButton
@onready var quit_button = $VBoxContainer/NinePatchRect/VBoxContainer/QuitButton

func _ready():
	play_button.pressed.connect(on_play_pressed)
	quit_button.pressed.connect(on_quit_pressed)

func on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func on_quit_pressed():
	get_tree().quit()
