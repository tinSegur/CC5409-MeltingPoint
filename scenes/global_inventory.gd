class_name Inventory
extends Node

class InternalStock:
	var material : MPMaterial
	var quantity : int = 0
	var quantDict : Dictionary = {}
	
	func _init(mat : MPMaterial, quant = 0):
		material = mat
		quantity = quant
		
		for s in mat.states:
			quantDict[s] = quant
	
	func add_amount(n : int, state : Statics.Material_states = Statics.Material_states.SOLID):
		quantDict[state] += n
	
	func set_amount(n : int, state : Statics.Material_states = Statics.Material_states.SOLID):
		quantDict[state] = n
	
	func get_amount(state : Statics.Material_states = Statics.Material_states.SOLID):
		return quantDict[state]

signal stock_change(mat_id : Statics.Materials, amount, 
	state : Statics.Material_states)

signal stock_variety(d : bool)


@export var materials : Array[MPMaterial]
var stocks : Dictionary

@onready var timer : Timer = $Timer

func _ready():
	for mat in materials:
		print("Init stock " + str(mat.type))
		stocks[mat.type] = InternalStock.new(mat)

func set_stock(id : Statics.Materials, amount : int, state : Statics.Material_states = Statics.Material_states.SOLID):
	if amount < 0:
		return
	var cur = stocks[id].get_amount(state)
	
	if amount == 0 and cur > 0:
		stock_variety.emit(false)
	elif cur == 0 and amount > 0:
		stock_variety.emit(true)
	
	stocks[id].set_amount(amount, state)
	if multiplayer.is_server():
		update_stock.rpc(id, stocks[id].get_amount(state), state)

func add_stock(id : Statics.Materials, amount : int = 1, state : Statics.Material_states = Statics.Material_states.SOLID):
	if stocks[id].get_amount(state) + amount < 0:
		return
	set_stock(id, stocks[id].get_amount(state) + amount, state)

func remove_stock(id : Statics.Materials, amount : int = 1, state : Statics.Material_states = Statics.Material_states.SOLID):
	set_stock(id, stocks[id].get_amount(state) - amount, state)

func check_stock(id : Statics.Materials, amount : int = 1, state : Statics.Material_states = Statics.Material_states.SOLID):
	return stocks[id].get_amount(state) >= amount

@rpc("call_remote", "reliable")
func update_stock(id, amount, state : Statics.Material_states = Statics.Material_states.SOLID):
	set_stock(id, amount, state)

@rpc("call_local", "reliable", "any_peer")
func add_resource(id : Statics.Materials, amount = 1, state : Statics.Material_states = Statics.Material_states.SOLID):
	if is_multiplayer_authority():
		add_stock(id, amount, state)


func _on_timer_timeout():
	for st in stocks:
		for state in stocks[st].material.states:
			stock_change.emit(stocks[st].material.type, stocks[st].get_amount(state), state)
