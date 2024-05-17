class_name UiInventoryItem
extends PanelContainer

var item_sprite : Texture2D

@onready var amount_label = $Label
@onready var text_rect = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	text_rect.set_texture(item_sprite)
	set_amount(0)

func set_amount(n : int):
	amount_label.set_text(kformat(n))

func kformat(n : int) -> String:
	var form : String = str(n)
	
	if n < 1000:
		return form
	
	var len : int  = len(form)
	var order : int = int(floor(len/3))
	var leading = len - order*3
	
	if leading == 0:
		form = form.substr(0, 2) + "." + form[3]
	else:
		form = form.substr(0, leading-1) + "." + form[leading]

	return form
