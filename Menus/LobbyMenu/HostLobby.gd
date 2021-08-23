extends LobbyMenu

onready var level_name = $MenuFrame/LobbyFrame/HostSettingsPanel/Level/LevelName
onready var num_laps = $MenuFrame/LobbyFrame/HostSettingsPanel/Laps/NumLaps
onready var num_npcs = $MenuFrame/LobbyFrame/HostSettingsPanel/NPCs/NumNPCs
onready var race_button = $MenuFrame/LobbyFrame/HostSettingsPanel/Buttons/RaceButton

var level_select : int = Network.multiplayer_level
var lap_amount : int = Network.multiplayer_lap_amount
var npc_amount : int = Network.multiplayer_npc_amount


func _ready():
	level_name.text = Network.level_dict_keys[level_select]
	num_laps.text = str(lap_amount)
	num_npcs.text = str(npc_amount)
	
	update_lobby_info("Lobby Created")


# Start Race Button
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
		level_select = Network.level_dict_keys.size() - 1
	level_name.text = Network.level_dict_keys[level_select]
	Network.multiplayer_level = level_select
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _level_select_right():
	level_select += 1
	if level_select > Network.level_dict_keys.size() - 1:
		level_select = 0
	level_name.text = Network.level_dict_keys[level_select]
	Network.multiplayer_level = level_select
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _decrease_lap_amount():
	lap_amount -= 1
	if lap_amount < Globals.MIN_LAP_NUMBER:
		lap_amount = Globals.MAX_LAP_NUMBER
	num_laps.text = str(lap_amount)
	Network.multiplayer_lap_amount = lap_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _increase_lap_amount():
	lap_amount += 1
	if lap_amount > Globals.MAX_LAP_NUMBER:
		lap_amount = Globals.MIN_LAP_NUMBER
	num_laps.text = str(lap_amount)
	Network.multiplayer_lap_amount = lap_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _check_max_npcs():
	if npc_amount > Network.max_npc_num:
		npc_amount = Network.max_npc_num
		num_npcs.text = str(npc_amount)
		Network.multiplayer_npc_amount = npc_amount
		
		Network.update_race_info(level_select, lap_amount, npc_amount)


func _decrease_NPC_amount():
	npc_amount -= 1
	if npc_amount < Globals.MIN_NPC_NUMBER:
		npc_amount = Network.max_npc_num
	num_npcs.text = str(npc_amount)
	Network.multiplayer_npc_amount = npc_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)


func _increase_NPC_amount():
	npc_amount += 1
	if npc_amount > Network.max_npc_num:
		npc_amount = Globals.MIN_NPC_NUMBER
	num_npcs.text = str(npc_amount)
	Network.multiplayer_npc_amount = npc_amount
	
	Network.update_race_info(level_select, lap_amount, npc_amount)
