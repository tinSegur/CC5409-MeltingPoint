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
@export var states : Array[Statics.Material_states] = [matter_states.SOLID, matter_states.LIQUID]

