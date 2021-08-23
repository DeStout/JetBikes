extends Player

var engine_rotation : Vector3


func _process(delta):
	engine_rotation = $EngineRotationHelper.rotation + \
					$EngineRotationHelper/Engine.rotation
	
	rset("puppet_transform", global_transform)
	rset("puppet_engine_rotation", engine_rotation)


func check_lap_number() -> void:
	if lap_number > Network.multiplayer_lap_amount:
		Network.player_finished()
	else:
		HUD.set_lap(lap_number)
