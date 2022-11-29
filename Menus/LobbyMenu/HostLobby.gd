extends LobbyMenu

var level_select : int = Globals.multiplayer_level
var lap_amount : int = Globals.multiplayer_laps_number
var npc_amount : int = Globals.multiplayer_NPC_number


func _ready():
	level_name.text = Globals.level_dict_keys[level_select]
	num_laps.text = str(lap_amount)
#	num_npcs.text = str(npc_amount)
	num_npcs.text = str(0)

	update_lobby_info("Lobby Created")


# Start Race Button
func _setup_race():
	Network.setup_online_multiplayer_race()


func update_lobby_info(update_type : String):
	.update_lobby_info(update_type)

	ready_button.disabled = false
	for player in Network.player_list:
		if !Network.player_list[player].is_ready:
			ready_button.disabled = true
			break

#	_check_max_npcs()


func reset_lobby():
	.reset_lobby()
	Network.update_player_ready(true)
#	get_tree().network_peer.refuse_new_connections = false


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
	if npc_amount > Globals.MAX_NPC_NUMBER:
		npc_amount = Globals.MAX_NPC_NUMBER
		num_npcs.text = str(npc_amount)
		Globals.multiplayer_NPC_number = npc_amount

		Network.update_race_info(level_select, lap_amount, npc_amount)


func _decrease_NPC_amount():
#	npc_amount -= 1
	if npc_amount < Globals.MIN_NPC_NUMBER:
		npc_amount = Globals.MAX_NPC_NUMBER
	num_npcs.text = str(npc_amount)
	Globals.multiplayer_NPC_number = npc_amount

#	Network.update_race_info(level_select, lap_amount, npc_amount)


func _increase_NPC_amount():
#	npc_amount += 1
	if npc_amount > Globals.MAX_NPC_NUMBER:
		npc_amount = Globals.MIN_NPC_NUMBER
	num_npcs.text = str(npc_amount)
	Globals.multiplayer_NPC_number = npc_amount

#	Network.update_race_info(level_select, lap_amount, npc_amount)
