extends Player


func _process(delta):
	rset("puppet_transform", global_transform)


func check_lap_number() -> void:
	if lap_number > Network.multiplayer_lap_amount:
		Network.player_finished()
	else:
		HUD.set_lap(lap_number)
