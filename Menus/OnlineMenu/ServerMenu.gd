extends Control


var lobby_list = []

onready var disconnect_button := $ButtonsContainer/DisconnectButton


func _ready() -> void:
	Network.connect("update_lobby_list", self, "update_lobby_list")

	disconnect_button.connect("pressed", Network, "reset_network")
	disconnect_button.connect("pressed", Globals.game.main_menu, "return_to_main")

	Network.get_lobby_list()

# Signaled from Network (update_lobby_list)
func update_lobby_list(new_lobby_list) -> void:
	lobby_list = new_lobby_list
	$LobbyList.clear()
	for lobby in lobby_list:
		$LobbyList.add_item(lobby[0])
		$LobbyList.add_item(lobby[1])
		$LobbyList.add_item(str(lobby[2]))
		$LobbyList.add_item(str(lobby[3]) + "/" + str(lobby[4]))
		$LobbyList.add_item(str(lobby[5]))


func _popup_lobby_creation() -> void:
	$LobbyCreation.popup()


func _create_new_lobby() -> void:
	Network.create_new_lobby($LobbyCreation/NameEdit.text)
	_hide_lobby_creation()


func _hide_lobby_creation() -> void:
	$LobbyCreation.visible = false
	$LobbyCreation/NameEdit.text = ""


func _select_row(selection_idx) -> void:
	var row = selection_idx / 5

	$LobbyList.select_mode = $LobbyList.SELECT_MULTI
	for i in range(5):
		$LobbyList.select(i + (row * 5), false)
	$LobbyList.select_mode = $LobbyList.SELECT_SINGLE
