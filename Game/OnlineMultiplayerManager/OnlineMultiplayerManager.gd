extends Node

signal return_to_main

var lobby


func _ready():
	lobby = $Lobby
	lobby.cancel_button.connect("pressed", self, "return_to_main")


func setup_lobby_network(is_host : bool):
	lobby.setup(is_host)
	
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	if !is_host:
		get_tree().connect("connected_to_server", self, "_connected_to_server")
		get_tree().connect("connection_failed", self, "_server_connection_failed")
		get_tree().connect("server_disconnected", self, "_server_disconnected")
	else:
		pass


func _peer_connected(new_peer_ID : int) -> void:
	pass


func _peer_disconnected(new_peer_ID : int) -> void:
	pass


func _connected_to_server() -> void:
	pass


func _server_connection_failed() -> void:
	emit_signal("return_to_main")


func server_disconnected() -> void:
	emit_signal("return_to_main")


func return_to_main():
	emit_signal("return_to_main")
