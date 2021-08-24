extends LobbyMenu

onready var level_name = $MenuFrame/LobbyFrame/ClientSettingsPanel/Level/LevelName
onready var num_laps = $MenuFrame/LobbyFrame/ClientSettingsPanel/Laps/NumLaps
onready var num_npcs = $MenuFrame/LobbyFrame/ClientSettingsPanel/NPCs/NumNPCs
onready var ready_button = $MenuFrame/LobbyFrame/ClientSettingsPanel/Buttons/ReadyButton

var connected_to_host = false


func _ready():
	Network.connect("connected_to_host", self, "connected_to_host")
	update_lobby_info("Lobby Created")


func connected_to_host():
	connected_to_host = true


func toggle_racer_ready(racer_ready : bool):
	ready_button.pressed = racer_ready
	Network.update_player_ready(racer_ready)


func update_lobby_info(update_type : String) -> void:
	.update_lobby_info(update_type)
	
	level_name.text = Globals.level_dict_keys[Network.multiplayer_level]
	num_laps.text = str(Network.multiplayer_lap_amount)
	num_npcs.text = str(Network.multiplayer_npc_amount)
