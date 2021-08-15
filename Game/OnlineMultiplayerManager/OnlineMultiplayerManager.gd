extends Node

signal return_to_main

var lobby

func _ready():
	lobby = $Lobby
	lobby.cancel_button.connect("pressed", self, "return_to_main")


func setup_lobby(is_host : bool):
	lobby.setup(is_host)


func return_to_main():
	emit_signal("return_to_main")
