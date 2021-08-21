extends LobbyMenu

onready var level_name = $MenuFrame/LobbyFrame/ClientSettingsPanel/Level/LevelName
onready var num_laps = $MenuFrame/LobbyFrame/ClientSettingsPanel/Laps/NumLaps
onready var num_npcs = $MenuFrame/LobbyFrame/ClientSettingsPanel/NPCs/NumNPCs
onready var ready_button = $MenuFrame/LobbyFrame/ClientSettingsPanel/Buttons/ReadyButton


func _ready():
	update_lobby_info("Lobby Created")


func _toggle_racer_ready(racer_ready : bool):
	Network.update_player_ready(racer_ready)


func update_lobby_info(update_type : String) -> void:
	.update_lobby_info(update_type)
	
	level_name.text = Globals.level_dict_keys[Network.multiplayer_level]
	num_laps.text = str(Network.multiplayer_laps_number)
	num_npcs.text = str(Network.multiplayer_NPC_number)
