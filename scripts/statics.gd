class_name Statics
extends Node


const MAX_CLIENTS = 2
const PORT = 5409


enum Role {
	NONE,
	ROLE_A,
	ROLE_B,
	ENGINEER,
	SCIENTIST,
	SCOUT

}

enum Materials {
	IRON,
	GOLD,
	CRYSTALS,
	ADVANCED
}

enum Material_states {
	SOLID,
	LIQUID,
	STABLE,
	UNSTABLE
}

enum INPUT_CODES {
	ACCEPT,
	NOTACCEPT
}


class PlayerData:
	var id: int
	var name: String
	var role: Role
	
	func _init(new_id: int, new_name: String, new_role: Role = Role.NONE) -> void:
		id = new_id
		name = new_name
		role = new_role
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"role": role
		}


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
