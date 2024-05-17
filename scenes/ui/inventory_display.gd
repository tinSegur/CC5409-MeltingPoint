extends HBoxContainer


var mat_displays : Dictionary
@export var display_item : PackedScene

@onready var global_inventory = get_tree().current_scene.get_node("Inventory")


func _ready():
	visible = false
	setup(global_inventory.materials)
	global_inventory.stock_change.connect(_set_display_amount)


func _process(delta):
	visible = Input.is_action_pressed("show_inventory")


func setup(icon_list : Array[MPMaterial]):
	for mat in icon_list:
		for st in mat.states:
			var new_ui = display_item.instantiate()
			new_ui.item_sprite = mat.solid_icon
			mat_displays[mat.type] = {}
			mat_displays[mat.type][st] = new_ui
			add_child(new_ui)

func _set_display_amount(id : Statics.Materials, amount : int, state : Statics.Material_states):
	pass
	#mat_displays[id][state].set_amount(amount)

