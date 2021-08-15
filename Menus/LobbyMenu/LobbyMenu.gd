extends Control

signal return_to_main

onready var level_setting = $MenuFrame/LobbyFrame/HostSettingsPanel/Level/LevelName
onready var laps_setting = $MenuFrame/LobbyFrame/HostSettingsPanel/Laps/NumLaps
onready var NPCs_setting = $MenuFrame/LobbyFrame/HostSettingsPanel/NPCs/NumNPCs
onready var cancel_button = $MenuFrame/LobbyFrame/CancelPanel/CancelButton

var multiplayer_lap_amount : int = Globals.DEFAULT_LAP_NUMBER
var multiplayer_NPC_amount : int = Globals.DEFAULT_NPC_NUMBER
var level_select : int = Globals.DEFAULT_LEVEL


func _ready():
	level_setting.text = Globals.level_dict_keys[Globals.DEFAULT_LEVEL]
	laps_setting.text = str(multiplayer_lap_amount)
	NPCs_setting.text = str(multiplayer_NPC_amount)


func setup(is_host : bool):
	if is_host:
		$MenuFrame/LobbyFrame/TitlePanel/Label.text = "Host Lobby"
		$MenuFrame/LobbyFrame/HostSettingsPanel.visible = true
		$MenuFrame/LobbyFrame/ClientSettingsPanel.visible = false
	else:
		$MenuFrame/LobbyFrame/TitlePanel/Label.text = "Client Lobby"
		$MenuFrame/LobbyFrame/HostSettingsPanel.visible = false
		$MenuFrame/LobbyFrame/ClientSettingsPanel.visible = true


func _level_select_left():
	level_select -= 1
	if level_select < 0:
		level_select = Globals.level_dict_keys.size() - 1
	level_setting.text = Globals.level_dict_keys[level_select]


func _level_select_right():
	level_select += 1
	if level_select > Globals.level_dict_keys.size() - 1:
		level_select = 0
	level_setting.text = Globals.level_dict_keys[level_select]


func _decrease_lap_amount():
	multiplayer_lap_amount -= 1
	if multiplayer_lap_amount < Globals.MIN_LAP_NUMBER:
		multiplayer_lap_amount = Globals.MAX_LAP_NUMBER
	laps_setting.text = str(multiplayer_lap_amount)


func _increase_lap_amount():
	multiplayer_lap_amount += 1
	if multiplayer_lap_amount > Globals.MAX_LAP_NUMBER:
		multiplayer_lap_amount = Globals.MIN_LAP_NUMBER
	laps_setting.text = str(multiplayer_lap_amount)


func _decrease_NPC_amount():
	multiplayer_NPC_amount -= 1
	if multiplayer_NPC_amount < Globals.MIN_NPC_NUMBER:
		multiplayer_NPC_amount = Globals.MAX_NPC_NUMBER
	NPCs_setting.text = str(multiplayer_NPC_amount)


func _increase_NPC_amount():
	multiplayer_NPC_amount += 1
	if multiplayer_NPC_amount > Globals.MAX_NPC_NUMBER:
		multiplayer_NPC_amount = Globals.MIN_NPC_NUMBER
	NPCs_setting.text = str(multiplayer_NPC_amount)


func _on_CancelButton_pressed():
	emit_signal("return_to_main")
