extends RigidBody2D

@onready var timer = $Timer

func _ready() -> void:
	timer.timeout.connect(queue_free)
