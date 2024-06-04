class_name InternalInventory
extends Node

@export var materials : Array[MPMaterial]
var stocks : Dictionary


func _init():
	for mat in materials:
		stocks[mat.type] = Statics.InternalStock.new(mat)

func set_stock(id : Statics.Materials, amount : int, state : Statics.Material_states = Statics.Material_states.SOLID):
	if stocks.has(id):
		stocks[id].set_amount(amount, state)

func add_stock(id : Statics.Materials, amount : int = 1, state : Statics.Material_states = Statics.Material_states.SOLID):
	if stocks.has(id):
		if stocks[id].get_amount(state) + amount < 0:
			return
		set_stock(id, stocks[id].get_amount(state) + amount, state)

func check_stock(id : Statics.Materials, amount : int = 1, state : Statics.Material_states = Statics.Material_states.SOLID):
	if !stocks.has(id):
		return false
	return stocks[id].get_amount(state) >= amount
