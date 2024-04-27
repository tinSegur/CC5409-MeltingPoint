class_name Inventory
extends Node

class InternalStock:
	var material : MPMaterial
	var quantity : int = 0
	
	func _init(mat : MPMaterial, quant = 0):
		material = mat
		quantity = quant
		
	func add_amount(n : int):
		quantity += n
	
	func set_amount(n : int):
		quantity = n

signal stock_change(mat_id : Statics.Materials, amount)


@export var materials : Array[MPMaterial]
var stocks : Dictionary

func _ready():
	for mat in materials:
		stocks[mat.type] = InternalStock.new(mat)



func set_stock(id : Statics.Materials, amount : int):
	if amount < 0:
		return
	stocks[id].set_amount(amount)
	Debug.sprint(stocks[id].quantity)
	update_stock.rpc(id, stocks[id].quantity)

func add_stock(id : Statics.Materials, amount : int = 1):
	set_stock(id, stocks[id].quantity + amount)

func remove_stock(id : Statics.Materials, amount : int = 1):
	set_stock(id, stocks[id].quantity - amount)

func check_stock(id : Statics.Materials, amount : int = 1):
	return stocks[id].quantity >= amount

@rpc("call_remote", "reliable")
func update_stock(id, amount):
	set_stock(id, amount)

@rpc("call_local", "reliable", "any_peer")
func add_resource(id : Statics.Materials, amount = 1):
	if is_multiplayer_authority():
		add_stock(id, amount)
		
