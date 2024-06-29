extends Node

@onready var play_button = %PlayButton
@onready var tips_button = %HelpButton
@onready var credits_button = %CreditsButton
@onready var quit_button = %QuitButton
@onready var credits_back_button = %CreditsBackButton

@onready var menu_container = %MenuContainer
@onready var credits = %Credits
@onready var tips_screen = %TipsScreen

@onready var items = $Items

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	tips_button.pressed.connect(_on_tips_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	credits_back_button.pressed.connect(_on_credits_back_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	tips_screen.previous_menu = menu_container
	

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_tips_pressed():
	menu_container.visible = false
	tips_screen.visible = true

func _on_quit_pressed():
	get_tree().quit()
	
func _on_credits_pressed():
	menu_container.visible = false
	credits.visible = true
	
func _on_credits_back_pressed():
	credits.visible = false
	menu_container.visible = true
