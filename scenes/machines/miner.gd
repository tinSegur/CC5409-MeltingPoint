extends StaticBody2D

var placed = false
@onready var hitbox = $Hitbox

func place():
	placed = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func is_valid_place() -> bool:
	var bodies: Array = hitbox.get_overlapping_bodies()
	return (bodies.size()-1) == 0
