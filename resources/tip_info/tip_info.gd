class_name MPTip
extends Resource

@export var name : String
@export var icon: Texture2D
@export_multiline var description : String
 
func render_info(parent_node: VBoxContainer):
	var name_label : Label = Label.new()
	name_label.text = name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent_node.add_child(name_label)
	
	if is_instance_valid(icon):
		var image : TextureRect = TextureRect.new()
		image.texture = icon
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(48,48)
		parent_node.add_child(image)
	
	var desc_label : RichTextLabel = RichTextLabel.new()
	desc_label.text = description
	desc_label.fit_content = true
	desc_label["theme_override_font_sizes/normal_font_size"] = 14
	parent_node.add_child(desc_label)
