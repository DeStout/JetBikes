extends Node

signal race_finished

var player_ : PackedScene = preload("res://Racers/Player/Player.tscn")
var player : Player
var player_spawn : Vector3
var crash_bike = preload("res://Racers/General/Bike/CrashBike.tscn")
var players : Array


func _ready() -> void:
#	if Globals.NPC_number != 0:
#		npc_ = preload("res://Racers/NPC/NPC.tscn")
	_spawn_players()
	players = get_children()
	players.erase($CrashBikes)


#func _process(delta : float) -> void:
#	players.sort_custom(self, "_sort_placement")
#	_alert_players()


func _spawn_players():
	player = player_.instance()
	player.connect("finished_race", self, "finish_race")
	add_child(player)
	player.global_transform = get_node("PlayerSpawn1").global_transform
	player_spawn = get_node("PlayerSpawn1").global_transform.origin
	player.set_racer_color(Globals.player_color)
	
	_setup_crash_bike(player)
	
	get_node("PlayerSpawn1").free()


func _setup_crash_bike(racer : Racer):
	racer.crash_bike = crash_bike.instance()
	$CrashBikes.add_child(racer.crash_bike)
	racer.crash_bike.set_bike_color(racer.get_racer_color())


func setup_players(track_navigation):
	player.navigation = track_navigation


func start_race() -> void:
	for racer in players:
		racer.start_race()


#func finish_race(winner) -> void:
#	if Globals.race_on_going:
#		player.HUD.set_race_notice("Finished!\n" + winner.name + " wins!", true)
#	for racer in players:
#		racer.finish_race()
#	emit_signal("race_finished")


#func _alert_players() -> void:
#	if get_child_count() - 1 == players.size():
#		for new_placement in range(players.size()):
#			players[new_placement].placement = new_placement + 1
#			if players[new_placement] is Player:
#				player.HUD.set_placement(new_placement + 1)
#	else:
#		push_error("Player Tracker child count does not match array size")


#func _sort_placement(player1 : KinematicBody, player2 : KinematicBody) -> bool:
#	if player1.lap_number > player2.lap_number:
#		return true
#	elif player2.lap_number > player1.lap_number:
#		return false
#	else:
#		var player1_serial = player1.current_path_node.serial
#		var player2_serial = player2.current_path_node.serial
#		if player1_serial == 0:
#			player1_serial = path_nodes_size
#		if player2_serial == 0:
#			player2_serial = path_nodes_size
#
#		if player1_serial > player2_serial:
#			return true
#		elif player2_serial > player1_serial:
#			return false
#		else:
#			if player1.path_node_distance < player2.path_node_distance:
#				return true
#			else:
#				return false
