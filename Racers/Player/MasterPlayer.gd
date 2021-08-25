extends Player

var engine_rotation : Vector3
var rset_quarter_timer : Timer = Timer.new()
var rset_twentieth_timer : Timer = Timer.new()


func _ready():
	rset_quarter_timer.start(0.25)
	rset_twentieth_timer.start(0.05)
	rset_quarter_timer.one_shot = true
	rset_twentieth_timer.one_shot = true


func _process(delta):
	engine_rotation = $EngineRotationHelper.rotation + \
					$EngineRotationHelper/Engine.rotation
	
	if !rset_twentieth_timer.time_left:
		rset("puppet_velocity", velocity)
		rset("puppet_engine_rotation", engine_rotation)
	
	if !rset_quarter_timer.time_left:
		rset("puppet_transform", global_transform)
		rset_quarter_timer.start(0.25)


func check_lap_number() -> void:
	if lap_number > Network.multiplayer_lap_amount:
		Network.player_finished()
	else:
		HUD.set_lap(lap_number)
