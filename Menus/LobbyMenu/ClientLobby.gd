extends LobbyMenu

signal failed_connection

onready var connect_menu = $MenuFrame/ConnectingFrame

onready var level_name = $MenuFrame/LobbyFrame/ClientSettingsPanel/Level/LevelName
onready var num_laps = $MenuFrame/LobbyFrame/ClientSettingsPanel/Laps/NumLaps
onready var num_npcs = $MenuFrame/LobbyFrame/ClientSettingsPanel/NPCs/NumNPCs

onready var ready_button = $MenuFrame/LobbyFrame/ClientSettingsPanel/Buttons/ReadyButton

var connected_to_host = false


func _ready():
	Network.connect("connected_to_host", self, "connected_to_host")
	$MenuFrame/ConnectingFrame.cancel_button = $MenuFrame/LobbyFrame/CancelPanel/CancelButton
	update_lobby_info("Lobby Created")

	# Restrict Client from joining "ghost" server
	for attempts in range(20):
		if connected_to_host:
			connect_menu.visible = false
			break
		yield(get_tree().create_timer(0.5), "timeout")
	$MenuFrame/ConnectingFrame/Timer.stop()
#
	if !connected_to_host:
		emit_signal("failed_connection")


func connected_to_host():
	connected_to_host = true


func toggle_racer_ready(racer_ready : bool):
	ready_button.pressed = racer_ready
	Network.update_player_ready(racer_ready)


func update_lobby_info(update_type : String) -> void:
	.update_lobby_info(update_type)

	level_name.text = Globals.level_dict_keys[Globals.multiplayer_level]
	num_laps.text = str(Globals.multiplayer_laps_number)
#	num_npcs.text = str(Globals.multiplayer_NPC_number)
	num_npcs.text = str(0)


func reset_lobby() -> void:
	.reset_lobby()
	toggle_racer_ready(false)
