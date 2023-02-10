extends Control


signal lobby_created

onready var lobby_list := $LobbyFrame/LobbyList
var list = []

onready var lobby_creation := $LobbyFrame/LobbyCreation
onready var disconnect_button := $LobbyFrame/ButtonsContainer/DisconnectButton


func _ready() -> void:
	Network.connect("update_lobby_list", self, "update_list")

	disconnect_button.connect("pressed", Network, "reset_network")
	disconnect_button.connect("pressed", Globals.game.main_menu, "return_to_main")

	Network.get_lobby_list()


# Signaled from Network (update_list)
func update_list(new_list) -> void:
	list = new_list
	lobby_list.clear()
	for lobby in list:
		lobby_list.add_item(lobby[0])
		lobby_list.add_item(lobby[1])
		lobby_list.add_item(str(lobby[2]))
		lobby_list.add_item(str(lobby[3]) + "/" + str(lobby[4]))
		lobby_list.add_item(str(lobby[5]))


func _popup_lobby_creation() -> void:
	lobby_creation.popup()


func _create_new_lobby() -> void:
	Network.create_new_lobby(lobby_creation.get_node("NameEdit").text)
	_hide_lobby_creation()
	emit_signal("lobby_created")


func _hide_lobby_creation() -> void:
	lobby_creation.visible = false
	lobby_creation.get_node("NameEdit").text = ""


func _select_row(selection_idx) -> void:
	var row = selection_idx / 5

	lobby_list.select_mode = lobby_list.SELECT_MULTI
	for i in range(5):
		lobby_list.select(i + (row * 5), false)
	lobby_list.select_mode = lobby_list.SELECT_SINGLE
