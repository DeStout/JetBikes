class_name LobbyMenu
extends Control

signal return_to_main

onready var racer_name : LineEdit = $LobbyFrame/RacerSettings/RacerName
onready var vehicle_color : ColorPickerButton = $LobbyFrame/RacerSettings/VehicleColor
onready var racer_list : ItemList = $LobbyFrame/RacersList/RacersList
onready var level_name = $LobbyFrame/RaceSettings/Level/LevelName
onready var num_laps = $LobbyFrame/RaceSettings/Laps/NumLaps
onready var num_npcs = $LobbyFrame/RaceSettings/NPCs/NumNPCs
onready var ready_button : Button = $LobbyFrame/ButtonsPanel/ReadyButton
onready var leave_button : Button = $LobbyFrame/ButtonsPanel/LeaveButton


func _enter_tree() -> void:
	yield(get_tree(), "idle_frame")
#	reset_lobby()


func _ready() -> void:
	Network.connect("update_lobby", self, "update_lobby_info")
	connect("return_to_main", Network, "close_network_connection")


func _racer_name_changed(new_text : String) -> void:
	Network.update_player_info(new_text, vehicle_color.color)


func _racer_color_changed(new_color : Color) -> void:
	Network.update_player_info(racer_name.text, new_color)


func update_lobby_info(_update_type : String) -> void:
#	print("Updating Lobby: " + _update_type)
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


#func reset_lobby():
#	Network.reset_racer()


func _leave() -> void:
	# Signal to Network (close_network_connection)
	emit_signal("return_to_main")
