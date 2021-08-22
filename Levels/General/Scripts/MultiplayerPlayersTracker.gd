extends Node

signal race_finished

var npc_ : PackedScene
var player_ : PackedScene = preload("res://Racers/SinglePlayer_Player/Player.tscn")
var master_player : Player
var crash_bike = preload("res://Racers/General/Bike/Assets/Models/CrashBike.tscn")
var players : Array
var path_nodes_size : int = 0


func _ready() -> void:
	if Globals.NPC_number != 0:
		npc_ = preload("res://Racers/SinglePlayer_NPC/NPC.tscn")
	_spawn_players()
	players = get_children()
	players.erase($CrashBikes)
	


func _process(delta : float) -> void:
#	players.sort_custom(self, "_sort_placement")
#	_alert_players()
	pass


func _spawn_players():
	# Spawn in and setup NPCs
#	if Network.multiplayer_npc_amount > 0:
#		for npc_num in range(Network.multiplayer_npc_amount):
#			var new_npc = npc_.instance()
#			add_child(new_npc)
#			new_npc.set_network_master(1)
#
#			new_npc.connect("finished_race", self, "finish_race")
#			new_npc.name = "NPC" + str(npc_num + 1)
#			new_npc.global_transform = get_node("PlayerSpawn" + str(npc_num+1)).global_transform
#			new_npc.set_racer_color(Color(randf(), randf(), randf()))
#
#			_setup_crash_bike(new_npc)
#
#			get_node("PlayerSpawn" + str(npc_num+1)).free()
	
	# Spawn in host and clients, host should be in last place
	var player_keys : Array = Network.player_list.keys()
	player_keys.invert()
	
	var player_num : int = 1
	
	for player in player_keys:
		var new_player : Player = player_.instance()
		add_child(new_player)
		new_player.set_network_master(player)
		if player == get_tree().get_network_unique_id():
			master_player = new_player
		
		new_player.connect("finished_race", self, "finish_race")
		if Network.player_list[player].player_name != "":
			new_player.name = Network.player_list[player].player_name
		else:
			new_player.name = Network.player_list[player].placeholder_name
#		var player_spawn : Spatial = get_node("PlayerSpawn" + str(player_num + \
#			Network.multiplayer_npc_amount))
		var player_spawn : Spatial = get_node("PlayerSpawn" + str(Network.MAX_CONNECTIONS - \
			player_num + 1))
		new_player.global_transform = player_spawn.global_transform
		new_player.set_racer_color(Network.player_list[player].color)
		
		_setup_crash_bike(new_player)
		player_spawn.free()
		
		player_num += 1
	
	# Delete remaining PlayerSpawn nodes
#	if Network.multiplayer_npc_amount + Network.player_list.size() < Network.MAX_CONNECTIONS:
#		for player_spawn in range(Network.multiplayer_npc_amount + Network.player_list.size() + 1, 13):
#			get_node("PlayerSpawn" + str(player_spawn)).queue_free()
	for player_spawn in range(1, Network.MAX_CONNECTIONS-player_keys.size()+1):
		var temp_node = get_node("PlayerSpawn" + str(player_spawn))
		temp_node.free()
	


func _setup_crash_bike(racer : Racer):
	racer.crash_bike = crash_bike.instance()
	if racer is Player:
		racer.crash_bike.set_materials(load("res://Racers/SinglePlayer_Player/Materials/M_PlayerBike.tres"), \
			load("res://Racers/SinglePlayer_Player/Materials/M_PlayerWindshield.tres"))
	elif racer is NPC:
		racer.crash_bike.set_materials(load("res://Racers/SinglePlayer_NPC/Materials/M_NPCBike.tres"), \
			load("res://Racers/SinglePlayer_NPC/Materials/M_NPCWindshield.tres"))
	$CrashBikes.add_child(racer.crash_bike)


func setup_players(track_navigation, path_nodes):
	path_nodes_size = path_nodes.size()
	
	master_player.navigation = track_navigation
	master_player.path_nodes = path_nodes
	master_player.current_path_node = path_nodes[0]
	
	if get_tree().get_network_unique_id() == 1:
		for npc_temp in players:
			if npc_temp is NPC:
				npc_temp.navigation = track_navigation
				npc_temp.path_nodes = path_nodes
				npc_temp.current_path_node = path_nodes[0]
				npc_temp.pathfind_next_node()


func start_race() -> void:
	if get_tree().get_network_unique_id() == 1:
		for racer in players:
			racer.start_race()
	else:
		master_player.start_race()


func finish_race(winner) -> void:
	if Globals.race_on_going:
		master_player.HUD.set_race_notice("Finished!\n" + winner.name + " wins!", true)
	if get_tree().get_network_unique_id() == 1:
		for racer in players:
			racer.finish_race()
	else:
		master_player.finish_race()
	emit_signal("race_finished")


func _alert_players() -> void:
	if get_tree().get_network_unique_id() == 1:
		for new_placement in range(players.size()):
			players[new_placement].placement = new_placement + 1
			if players[new_placement] is Player:
				master_player.HUD.set_placement(new_placement + 1)


func _sort_placement(player1 : KinematicBody, player2 : KinematicBody) -> bool:
	if player1.lap_number > player2.lap_number:
		return true
	elif player2.lap_number > player1.lap_number:
		return false
	else:
		var player1_serial = player1.current_path_node.serial
		var player2_serial = player2.current_path_node.serial
		if player1_serial == 0:
			player1_serial = path_nodes_size
		if player2_serial == 0:
			player2_serial = path_nodes_size
			
		if player1_serial > player2_serial:
			return true
		elif player2_serial > player1_serial:
			return false
		else:
			if player1.path_node_distance < player2.path_node_distance:
				return true
			else:
				return false
