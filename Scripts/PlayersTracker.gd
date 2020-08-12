extends Node

var npc
var player = load("res://Scenes/Player.tscn")
var players : Array
var path_nodes_size : int

signal race_finished

func _ready() -> void:
	if Globals.NPC_number != 0:
		npc = load("res://Scenes/NPC.tscn")
	_spawn_players()
	players = get_children()
	
func _process(delta : float) -> void:
	players.sort_custom(self, "_sort_placement")
	_alert_players()
		
func _spawn_players():
	player = player.instance()
	player.connect("race_finished", self, "finish_race")
	player.connect("update_HUD_lap", self, "update_HUD_lap")
	add_child(player)
	player.global_transform.origin = get_node("PlayerSpawn"+str(Globals.NPC_number+1)).global_transform.origin
	
	if Globals.NPC_number > 0:
		for NPC_num in range(Globals.NPC_number):
			var new_NPC = npc.instance()
			new_NPC.name = "NPC" + str(NPC_num + 1)
			new_NPC.connect("race_finished", self, "finish_race")
			add_child(new_NPC)
			new_NPC.global_transform.origin = get_node("PlayerSpawn"+str(NPC_num+1)).global_transform.origin
			get_node("PlayerSpawn"+str(NPC_num+1)).free()
	
	for spawn in range(Globals.NPC_number+1, 13):
		get_node("PlayerSpawn"+str(spawn)).free()
	
func start_race() -> void:
	for p in players:
		p.start_race()
	
func finish_race() -> void:
	for p in players:
		p.finish_race()
	emit_signal("race_finished")
	
func _alert_players() -> void:
	if get_child_count() == players.size():
		for new_placement in range(players.size()):
			players[new_placement].placement = new_placement + 1
			if players[new_placement] is Player:
				Globals.game.single_player_manager.set_player_placement(new_placement + 1)
	else:
		push_error("Player Tracker child count does not match array size")

func _sort_placement(player1 : KinematicBody, player2 : KinematicBody) -> bool:
	if !path_nodes_size:
		path_nodes_size = player.path_nodes.size()
		
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

func update_HUD_lap(var new_lap_number : int) -> void:
	Globals.game.single_player_manager.set_player_lap(new_lap_number)
