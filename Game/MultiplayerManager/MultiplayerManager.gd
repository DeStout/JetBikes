extends Node

signal return_to_main

var host_lobby_ : PackedScene = preload("res://Menus/LobbyMenu/HostLobby.tscn")
var client_lobby_ : PackedScene = preload("res://Menus/LobbyMenu/ClientLobby.tscn")
var connect_menu_ : PackedScene = preload("res://Menus/LobbyMenu/ConnectingMenu.tscn")
var _lobby : Control

var _multiplayer_track : Track = null


func _ready() -> void:
	Network.connect("setup_track", self, "setup_track")
	
	# Called by Host and Client
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	# Only called by Client
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_server_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func setup_track() -> void:
	Network.update_player_ready(false)
	
	_multiplayer_track = Network.level_dict[Network.level_dict_keys[Network.multiplayer_level]].instance()
	
	remove_child(_lobby)
	add_child(_multiplayer_track)
	
	_multiplayer_track.connect("return_to_lobby", self, "return_to_lobby")
	_multiplayer_track.get_node("Players").master_player \
					.pause_menu.connect("leave_race", self, "return_to_main")


func setup_lobby_network(is_host : bool) -> void:
	var connection : int = FAILED
	if is_host:
		connection = Network.init_host()
	else:
		connection = Network.init_client()
		
		# Restrict Client from joining "ghost" server
		var _connect_menu = connect_menu_.instance()
		add_child(_connect_menu)
		_connect_menu.cancel_button.connect("pressed", self, "return_to_main")
		
		for attempts in range(20):
			if false:
				connection = OK
				break
			else:
				connection = ERR_CANT_CONNECT
			yield(get_tree().create_timer(0.5), "timeout")
		_connect_menu.queue_free()
	
	if connection == OK:
		if is_host:
			_lobby = host_lobby_.instance()
		else:
			_lobby = client_lobby_.instance()
		add_child(_lobby)
		_lobby.cancel_button.connect("pressed", self, "return_to_main")
			
	else:
		print("Failed Server Connection - Returning to Main Menu")
		emit_signal("return_to_main")


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
	emit_signal("return_to_main")


func _server_disconnected() -> void:
	print("Server Disconnected - Returning to Main Menu")
	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.queue_free()
	Network.close_network_connection()
	emit_signal("return_to_main")


func return_to_lobby() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if !get_tree().is_network_server():
		_lobby.toggle_racer_ready(false)
	
	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.queue_free()
		remove_child(_multiplayer_track)
		
		add_child(_lobby)


func return_to_main() -> void:
	if is_instance_valid(_lobby):
		_lobby.queue_free()
	if is_instance_valid(_multiplayer_track):
		_multiplayer_track.queue_free()
	Network.close_network_connection()
	print("Lobby Closed - Returning to Main Menu")
	emit_signal("return_to_main")
