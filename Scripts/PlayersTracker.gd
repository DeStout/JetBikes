extends Node

var players : Array

func _ready() -> void:
	players = get_children()
	_alert_players()
	
func _process(delta) -> void:
	players.sort_custom(self, "_sort_placement")
	_alert_players()
	
func _alert_players() -> void:
	if get_child_count() == players.size():
		for new_placement in range(players.size()):
			players[new_placement].placement = new_placement + 1
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
			player1_serial = 11
		if player2_serial == 0:
			player2_serial = 11
			
		if player1_serial > player2_serial:
			return true
		elif player2_serial > player1_serial:
			return false
		else:
			if player1.path_node_distance < player2.path_node_distance:
				return true
			else:
				return false
