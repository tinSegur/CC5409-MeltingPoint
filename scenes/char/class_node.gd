extends Node2D

@export var data_dict = {}


func get_data(class_id) -> Dictionary:
	return data_dict[class_id]
	
	
