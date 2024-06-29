class_name MPBuildInfo
extends Resource

@export var name : String
@export var icon: Texture2D
@export var button : Texture2D
@export var b_pressed : Texture2D
@export var b_hover : Texture2D
@export_multiline var description : String
@export var costs : Array[MPCost]
@export_file var machine_scene
 

func render_info(parent_node: VBoxContainer):
	var name_label : Label = Label.new()
	name_label.text = name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent_node.add_child(name_label)
	
	var image : TextureRect = TextureRect.new()
	image.texture = icon
	image.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(48,48)
	parent_node.add_child(image)
	
	var desc_label : RichTextLabel = RichTextLabel.new()
	desc_label.text = description
	desc_label.fit_content = true
	desc_label["theme_override_font_sizes/normal_font_size"] = 16
	parent_node.add_child(desc_label)
	
	var cost_grid : GridContainer = GridContainer.new()
	cost_grid.columns = 4
	parent_node.add_child(cost_grid)
	
	for cost in costs:
		var cost_icon : TextureRect = TextureRect.new()
		cost_icon.texture = cost.icon
		cost_icon.custom_minimum_size = Vector2(16,16)
		cost_grid.add_child(cost_icon)
		
		var cost_label : Label = Label.new()
		cost_label.text = str(cost.amount)
		cost_label["theme_override_font_sizes/font_size"] = 8
		cost_grid.add_child(cost_label)
