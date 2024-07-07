extends Node

signal players_updated
signal player_updated(id)

@export var multiplayer_test = true

# [ {id: int, name: string, rol: Rol} ]
var players: Array[Statics.PlayerData] = []

# first one is server
@export var test_players: Array[PlayerDataResource] = []

# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed(error)

signal new_player(player: Statics.PlayerData)
signal spawn_new_player(id: int)
signal player_added(player: Statics.PlayerData)

# Replace this with your own server port number between 1024 and 65535.
const SERVER_PORT = 5409
var thread = null

func add_player(player: Statics.PlayerData) -> void:
	Debug.sprint("Add player")
	players.append(player)
	players_updated.emit()


func remove_player(id: int) -> void:
	for i in players.size():
		if players[i].id == id:
			players.remove_at(i)
			break
	players_updated.emit()


func get_player(id: int) -> Statics.PlayerData:
	for player in players:
		if player.id == id:
			return player
	return null


func get_current_player() -> Statics.PlayerData:
	return get_player(multiplayer.get_unique_id())


@rpc("any_peer", "reliable", "call_local")
func set_player_role(id: int, role: Statics.Role) -> void:
	var player = get_player(id)
	player.role = role
	player_updated.emit(id)


func set_current_player_role(role: Statics.Role) -> void:
	set_player_role.rpc(multiplayer.get_unique_id(), role)


func is_online() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer and \
		multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED

func get_player_instance(id: int) -> CharacterBody2D:
	return get_tree().current_scene.get_node("Players").get_node(str(id))

func _upnp_setup(server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()
	
	print("discover")
	
	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return

	var gateway = upnp.get_gateway()
	if gateway and gateway.is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		print("signal2")
		
		emit_signal("upnp_completed", OK)

func _ready():
	thread = Thread.new()
	thread.start(_upnp_setup.bind(SERVER_PORT))
	print("start")

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()

func player_connecting(id: int):
	Debug.sprint("Sending data")
	var player = get_current_player()
	send_current_player_data.rpc_id(id, player.id, player.name, player.role)

@rpc("authority", "reliable")
func send_current_player_data(id: int, name: String, role: Statics.Role):
	Debug.sprint("Game add player")
	var player_data = Statics.PlayerData.new(id, name, role)
	add_player(player_data)
	player_added.emit(player_data)

func add_new_player(id: int, name: String):
	_add_new_player.rpc(id, name)

@rpc("any_peer", "call_remote", "reliable")
func _add_new_player(id: int, name: String):
	Debug.sprint("add_new_player")
	var player_data = Statics.PlayerData.new(id, name)
	add_player(player_data)

@rpc("any_peer", "reliable")
func send_info(info_dict: Dictionary) -> void:
	if is_instance_valid(Game.get_player(info_dict.id)):
		return
	var player = Statics.PlayerData.new(info_dict.id, info_dict.name, info_dict.role)
	add_player(player)
	send_info.rpc_id(multiplayer.get_remote_sender_id(), Game.get_current_player().to_dict())
	new_player.emit(player)

@rpc("any_peer", "reliable", "call_remote")
func new_player_ready(id: int):
	spawn_new_player.emit(id)
	
@rpc("any_peer","call_local","reliable")
func test_rpc():
	Debug.sprint("TestPrint")
