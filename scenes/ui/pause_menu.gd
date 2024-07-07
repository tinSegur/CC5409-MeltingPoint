extends MarginContainer
@onready var resume = %Resume
@onready var tips = %Tips
@onready var quit = %Quit
@onready var tips_screen = $TipsScreen
@onready var pause_container = $PauseContainer

signal quit_pressed

func _ready():
	resume.pressed.connect(_on_resume_pressed)
	tips.pressed.connect(_on_tips_pressed)
	quit.pressed.connect(_on_quit_pressed)
	tips_screen.previous_menu = pause_container
	
func _on_resume_pressed():
	visible = false

func _on_tips_pressed():
	pause_container.visible = false
	tips_screen.visible = true

func _on_quit_pressed():
	quit_pressed.emit()
