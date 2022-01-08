extends Node

signal race_finished

var npc_ : PackedScene
var player_ : PackedScene = preload("res://Racers/Player/Player.tscn")
var player : Player
var crash_bike = preload("res://Racers/General/Bike/CrashBike.tscn")
var path_follow_ = preload("res://Racers/NPC/PathFollow.tscn")
var players : Array
var path_nodes_size : int = 0


func _ready() -> void:
	if Globals.NPC_number != 0:
		npc_ = preload("res://Racers/NPC/NPC.tscn")
	_spawn_players()
	players = get_children()
	players.erase($CrashBikes)


func _process(delta : float) -> void:
	players.sort_custom(self, "_sort_placement")
	_alert_players()


func _spawn_players():
	player = player_.instance()
	player.connect("finished_race", self, "finish_race")
	add_child(player)
	player.global_transform = get_node("PlayerSpawn"+str(Globals.NPC_number+1)).global_transform
	player.set_racer_color(Globals.player_color)
	
	_setup_crash_bike(player)
	
	if Globals.NPC_number > 0:
		for NPC_num in range(Globals.NPC_number):
			var new_NPC = npc_.instance()
			new_NPC.connect("finished_race", self, "finish_race")
			add_child(new_NPC)
			
			new_NPC.name = "NPC" + str(NPC_num + 1)
			new_NPC.global_transform = get_node("PlayerSpawn"+str(NPC_num+1)).global_transform
			new_NPC.set_racer_color(Color(randf(), randf(), randf()))

			_setup_crash_bike(new_NPC)
			
			get_node("PlayerSpawn"+str(NPC_num+1)).free()
	
	for spawn in range(Globals.NPC_number+1, 13):
		get_node("PlayerSpawn"+str(spawn)).free()


func _setup_crash_bike(racer : Racer):
	racer.crash_bike = crash_bike.instance()
	$CrashBikes.add_child(racer.crash_bike)
	
	racer.crash_bike.set_bike_color(racer.get_racer_color())


func setup_players(path, path_nodes):
	path_nodes_size = path_nodes.size()
	
	player.HUD.set_max_laps(Globals.laps_number)
#	player.navigation = track_navigation
	player.path = path
	player.path_nodes = path_nodes
	player.current_path_node = path_nodes[0]
	
	for npc_temp in players:
		if npc_temp is NPC:
#			npc_temp.navigation = track_navigation
			npc_temp.path = path
			
			var new_path_follow = path_follow_.instance()
			path.add_child(new_path_follow)
			new_path_follow.rotation_mode = PathFollow.ROTATION_ORIENTED
			var path_variability = 20
			new_path_follow.h_offset = randf() * path_variability - (path_variability / 2)
			npc_temp.path_follow = new_path_follow
			new_path_follow.npc = npc_temp
			
			npc_temp.path_nodes = path_nodes
			npc_temp.current_path_node = path_nodes[0]
#			npc_temp.pathfind_next_node()


func start_race() -> void:
	for racer in players:
		racer.start_race()


func finish_race(winner) -> void:
	if Globals.race_on_going:
		player.HUD.set_race_notice("Finished!\n" + winner.name + " wins!", true)
	for racer in players:
		racer.finish_race()
	emit_signal("race_finished")


func _alert_players() -> void:
	if get_child_count() - 1 == players.size():
		for new_placement in range(players.size()):
			players[new_placement].placement = new_placement + 1
			if players[new_placement] is Player:
				player.HUD.set_placement(new_placement + 1)
	else:
		push_error("Player Tracker child count does not match array size")


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
