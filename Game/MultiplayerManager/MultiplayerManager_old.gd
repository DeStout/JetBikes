extends Node

signal return_to_main

var game : Node = null

var host_lobby_ : PackedScene = preload("res://Menus/OnlineMenu/old_menu/HostLobby.tscn")
var client_lobby_ : PackedScene = preload("res://Menus/OnlineMenu/old_menu/ClientLobby.tscn")
var _lobby : Control

var level_loader_ = preload("res://Menus/LoadingMenu/LoadingMenu.tscn")
var _multiplayer_track = null


func _ready() -> void:
	Network.connect("setup_track", self, "setup_track")
	Network.connect("end_race", self, "return_to_lobby")

	# Called by Host and Client
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	# Only called by Client
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_server_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func setup_track() -> void:
	Globals.is_multiplayer = true
	remove_child(_lobby)

	var level_loader = level_loader_.instance()
	add_child(level_loader)
	level_loader.load_track(Globals.level_dict[Globals.level_dict_keys[Globals.multiplayer_level]])
	_multiplayer_track = yield(level_loader, "track_loaded")

	_multiplayer_track = _multiplayer_track.instance()
	get_parent().remove_child(get_parent().main_menu)
	add_child(_multiplayer_track)
	_multiplayer_track.connect("return_to_main", self, "return_to_lobby")

	level_loader.queue_free()


func setup_lobby_network(is_host : bool) -> void:
	var connection : int = FAILED
	if is_host:
		_lobby = host_lobby_.instance()
		connection = Network.init_host()
	else:
		_lobby = client_lobby_.instance()
		_lobby.connect("failed_connection", self, "return_to_main")
		_lobby.get_node("ConnectingMenu/CancelButton").connect("pressed", self, "return_to_main")
		connection = Network.init_client()

	if connection == OK:
		add_child(_lobby)
		_lobby.leave_button.connect("pressed", self, "return_to_main")
	else:
		print("Failed Server Connection - Returning to Main Menu")
		return_to_main()


func _peer_connected(new_peer_ID : int) -> void:
	print("New Peer Connected: " + str(new_peer_ID))
	Network.add_peer(new_peer_ID)

	if get_tree().is_network_server():
		Network.give_new_peer_player_data(new_peer_ID)


func _peer_disconnected(dead_peer_ID : int) -> void:
	print("Peer Disonnected: " + str(dead_peer_ID))
	Network.remove_dead_peer(dead_peer_ID)
	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.get_node("Players").remove_lame_racer(dead_peer_ID)


func _connected_to_server() -> void:
	print("Connected to Server: " + str(Network.self_data.network_ID))


func _server_connection_failed() -> void:
	print("Failed Server Connection - Returning to Main Menu")
	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.queue_free()
	if is_instance_valid(_lobby):
		_lobby.queue_free()
	emit_signal("return_to_main")


func _server_disconnected() -> void:
	print("Server Disconnected - Returning to Main Menu")
	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.queue_free()
	if is_instance_valid(_lobby):
		_lobby.queue_free()
	Network.close_network_connection()
	emit_signal("return_to_main")


func return_to_lobby() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.queue_free()
		remove_child(_multiplayer_track)

	print("Race Finished - Returning to Lobby")
	get_parent().add_child(get_parent().main_menu)
	get_parent().move_child(self, 1)
	add_child(_lobby)


func return_to_main() -> void:
	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.queue_free()
	if is_instance_valid(_lobby):
		_lobby.queue_free()

	Network.close_network_connection()
	print("Lobby Closed - Returning to Main Menu")
	emit_signal("return_to_main")