class_name MPMaterial
extends Resource

var matter_states = Statics.Material_states

@export var inventory_sprite : Texture
@export var type : Statics.Materials
@export var melting_point : int = 2
@export var breaking_delta : float = 100.0 
@export var can_break : bool = false
@export var can_melt : bool = true
@export var melt_icon : Texture2D
@export var solid_icon : Texture2D
@export var default_temp : int = 5
@export var melt_speed : float = 0.02
@export var states : Array[Statics.Material_states] = [matter_states.SOLID, matter_states.LIQUID]
@export var state_sprites : Dictionary = {matter_states.SOLID : null, matter_states.LIQUID : null}

func get_sprite_by_state(state : Statics.Material_states) -> Texture2D:
	if state == matter_states.SOLID or state == matter_states.STABLE:
		return solid_icon
	elif state == matter_states.LIQUID or state == matter_states.UNSTABLE:
		return melt_icon
	else:
		return solid_icon
