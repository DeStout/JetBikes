extends LobbyMenu

onready var level_name = $MenuFrame/LobbyFrame/HostSettingsPanel/Level/LevelName
onready var num_laps = $MenuFrame/LobbyFrame/HostSettingsPanel/Laps/NumLaps
onready var num_npcs = $MenuFrame/LobbyFrame/HostSettingsPanel/NPCs/NumNPCs
onready var race_button = $MenuFrame/LobbyFrame/HostSettingsPanel/Buttons/RaceButton

var lap_amount : int = Globals.DEFAULT_LAP_NUMBER
var npc_amount : int = Globals.DEFAULT_NPC_NUMBER
var level_select : int = Globals.DEFAULT_LEVEL


func _ready():
	level_name.text = Globals.level_dict_keys[Globals.DEFAULT_LEVEL]
	num_laps.text = str(lap_amount)
	num_npcs.text = str(npc_amount)
	
	update_lobby_info("Lobby Created")


func _setup_race():
	Network.setup_online_multiplayer_race()


func update_lobby_info(update_type : String):
	.update_lobby_info(update_type)
	
	race_button.disabled = false
	for player in Network.player_list:
		if !Network.player_list[player].is_ready:
			race_button.disabled = true
			break
	
	_check_max_npcs()


func _level_select_left():
	level_select -= 1
	if level_select < 0:
		level_select = Globals.level_dict_keys.size() - 1
	level_name.text = Globals.level_dict_keys[level_select]
	Globals.multiplayer_level = level_select
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _level_select_right():
	level_select += 1
	if level_select > Globals.level_dict_keys.size() - 1:
		level_select = 0
	level_name.text = Globals.level_dict_keys[level_select]
	Globals.multiplayer_level = level_select
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _decrease_lap_amount():
	lap_amount -= 1
	if lap_amount < Globals.MIN_LAP_NUMBER:
		lap_amount = Globals.MAX_LAP_NUMBER
	num_laps.text = str(lap_amount)
	Globals.multiplayer_laps_number = lap_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _increase_lap_amount():
	lap_amount += 1
	if lap_amount > Globals.MAX_LAP_NUMBER:
		lap_amount = Globals.MIN_LAP_NUMBER
	num_laps.text = str(lap_amount)
	Globals.multiplayer_laps_number = lap_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _check_max_npcs():
	if npc_amount > Network.max_npc_num:
		npc_amount = Network.max_npc_num
		num_npcs.text = str(npc_amount)
		Globals.multiplayer_NPC_number = npc_amount
		
		Network.update_race_info(level_select, lap_amount, npc_amount)


func _decrease_NPC_amount():
	npc_amount -= 1
	if npc_amount < Globals.MIN_NPC_NUMBER:
		npc_amount = Network.max_npc_num
	num_npcs.text = str(npc_amount)
	Globals.multiplayer_NPC_number = npc_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _increase_NPC_amount():
	npc_amount += 1
	if npc_amount > Network.max_npc_num:
		npc_amount = Globals.MIN_NPC_NUMBER
	num_npcs.text = str(npc_amount)
	Globals.multiplayer_NPC_number = npc_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)
