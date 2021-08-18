extends Node

signal return_to_main

var lobby


func _ready():
	lobby = $Lobby
	lobby.cancel_button.connect("pressed", self, "return_to_main")


func setup_lobby_network(is_host : bool):
	lobby.setup(is_host)
	
	get_tree().connect("network_peer_connected", self, "")
	get_tree().connect("network_peer_disconnected", self, "")
	if !is_host:
		get_tree().connect("connected_to_server", self, "")
		get_tree().connect("connection_failed", self, "")
		get_tree().connect("server_disconnected", self, "")
	else:
		pass


func return_to_main():
	emit_signal("return_to_main")
