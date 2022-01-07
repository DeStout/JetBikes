extends Node

signal race_finished

var npc_ : PackedScene
var player_ : PackedScene = load("res://Racers/Player/MasterPlayer.tscn")
var puppet_racer_ : PackedScene = load("res://Racers/PuppetRacer/PuppetRacer.tscn")
var crash_bike = preload("res://Racers/General/Bike/CrashBike.tscn")

var master_player : Player
var players : Array
var path_nodes_size : int = 0


func _ready() -> void:
	Network.connect("finish_race", self, "finish_race")
	
	if Globals.NPC_number != 0:
		npc_ = load("res://Racers/NPC/NPC.tscn")
	_spawn_players()
	players = get_children()
	players.erase($CrashBikes)
	


func _process(delta : float) -> void:
#	players.sort_custom(self, "_sort_placement")
#	_alert_players()
	pass


func _spawn_players():
	#
	# Spawn in and setup NPCs
	#
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
	
	var player_num : int = 1
	
	var player_keys : Array = Network.player_list.keys()
#	player_keys.invert()
	
	for player in player_keys:
		var new_player
		if player == get_tree().get_network_unique_id():
			new_player = player_.instance()
			master_player = new_player
#			new_player.connect("finished_race", self, "finish_race")
		else:
			new_player = puppet_racer_.instance()
		
		add_child(new_player)
		new_player.set_network_master(player)
		new_player.name = str(player)
		new_player.player_name = Network.player_list[player].player_name
			
#		var player_spawn : Spatial = get_node("PlayerSpawn" + str(player_num + \
#			Network.multiplayer_npc_amount))
		var player_spawn : Spatial = get_node("PlayerSpawn" + str(Network.MAX_CONNECTIONS - \
			player_num + 1))
			
		if new_player is PuppetRacer:
			new_player.puppet_transform = player_spawn.global_transform
		else:
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


func _setup_crash_bike(player):
	player.crash_bike = crash_bike.instance()
	player.crash_bike.set_bike_color(player.get_racer_color())
	$CrashBikes.add_child(player.crash_bike)


func setup_players(track_navigation, path, path_nodes):
	path_nodes_size = path_nodes.size()
	
	master_player.HUD.set_max_laps(Network.multiplayer_lap_amount)
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


func remove_lame_racer(lame_peer_ID) -> void:
	for lame_peer in players:
		if lame_peer.get_network_master() == lame_peer_ID:
			players.remove(players.find(lame_peer))
			lame_peer.queue_free()
			break


func start_race() -> void:
	for racer in players:
		if racer is Racer:
			racer.start_race()


func finish_race(winner_name) -> void:
	master_player.HUD.set_race_notice("Finished!\n" + winner_name + " wins!", true)
	# Called to Racer
	master_player.finish_race()
	# Signal to Track
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
