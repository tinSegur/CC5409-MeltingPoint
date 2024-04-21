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

@export var materials : Array[MPMaterial]
var stocks : Dictionary

func _ready():
	for mat in materials:
		stocks[mat.type] = InternalStock.new(mat)

@rpc("call_local", "reliable")
func add_resource(id : Statics.Materials, amount = 1):
	stocks[id].add_amount(amount)
	Debug.sprint(stocks[id].quantity)

