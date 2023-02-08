extends Control


onready var disconnect_button := $ButtonsContainer/DisconnectButton


func _ready() -> void:
	disconnect_button.connect("pressed", Network, "reset_network")
	disconnect_button.connect("pressed", Globals.game.main_menu, "return_to_main")


func _select_row(selection_idx) -> void:
	var row = selection_idx / 5

	$ItemList.select_mode = $ItemList.SELECT_MULTI
	for i in range(5):
		$ItemList.select(i + (row * 5), false)
	$ItemList.select_mode = $ItemList.SELECT_SINGLE
