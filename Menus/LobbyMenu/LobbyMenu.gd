class_name LobbyMenu
extends Control

signal return_to_main

onready var racer_name : LineEdit = $MenuFrame/LobbyFrame/RacerSettingsPanel/RacerName
onready var vehicle_color : ColorPickerButton = $MenuFrame/LobbyFrame/RacerSettingsPanel/VehicleColor
onready var racer_list : ItemList = $MenuFrame/LobbyFrame/ListPanel/RacersList

onready var cancel_button : Button = $MenuFrame/LobbyFrame/CancelPanel/CancelButton


func _ready() -> void:
	Network.connect("update_lobby", self, "update_lobby_info")
	connect("return_to_main", Network, "close_network_connection")


func _racer_name_changed(new_text : String) -> void:
	Network.update_player_info(new_text, vehicle_color.color)


func _racer_color_changed(new_color : Color) -> void:
	Network.update_player_info(racer_name.text, new_color)


func update_lobby_info(update_type : String) -> void:
#	print("Updating Lobby: " + update_type)

	if is_inside_tree():
		racer_list.clear()
		for player in Network.player_list:
			# Keep local placeholder name updated
			if player == get_tree().get_network_unique_id():
				racer_name.placeholder_text = Network.player_list[player].placeholder_name

			# Update player's names or use placeholder name
			if Network.player_list[player].player_name != "":
				racer_list.add_item(Network.player_list[player].player_name, null, false)
			else:
				racer_list.add_item(Network.player_list[player].placeholder_name, null, false)

			# Update player's colors
			racer_list.set_item_custom_fg_color(racer_list.get_item_count()-1, \
				Network.player_list[player].color)

			# Update player's ready
			if Network.player_list[player].is_ready:
				racer_list.add_item("Ready", null, false)
			else:
				racer_list.add_item("", null, false)

			racer_list.set_item_selectable(racer_list.get_item_count()-1, 0)


func reset_lobby():
	Network.track_ready(false)
	Network.is_in_race(false)


func _on_CancelButton_pressed() -> void:
	# Signal to Network (close_network_connection)
	emit_signal("return_to_main")
