extends Control


var lobby_list = []

onready var disconnect_button := $ButtonsContainer/DisconnectButton


func _ready() -> void:
	Network.connect("update_lobby_list", self, "update_lobby_list")

	disconnect_button.connect("pressed", Network, "reset_network")
	disconnect_button.connect("pressed", Globals.game.main_menu, "return_to_main")

	Network.get_lobby_list()


func update_lobby_list(new_lobby_list) -> void:
	lobby_list = new_lobby_list
	print(lobby_list)


func _select_row(selection_idx) -> void:
	var row = selection_idx / 5

	$ItemList.select_mode = $ItemList.SELECT_MULTI
	for i in range(5):
		$ItemList.select(i + (row * 5), false)
	$ItemList.select_mode = $ItemList.SELECT_SINGLE
