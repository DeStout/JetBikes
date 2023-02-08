extends Control


onready var disconnect_button := $ButtonsContainer/DisconnectButton


func _ready() -> void:
	disconnect_button.connect("pressed", Network, "reset_network")
	disconnect_button.connect("pressed", Globals.game.main_menu, "return_to_main")
