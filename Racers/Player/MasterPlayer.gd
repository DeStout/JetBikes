extends Player

var player_name : String

var engine_rotation
#var rset_quarter_timer : Timer = Timer.new()
#var rset_twentieth_timer : Timer = Timer.new()


#func _ready():
#	add_child(rset_quarter_timer)
#	add_child(rset_twentieth_timer)
#	rset_quarter_timer.one_shot = true
#	rset_twentieth_timer.one_shot = true
#	rset_quarter_timer.start(0.25)
#	rset_twentieth_timer.start(0.05)


func _physics_process(delta):
	engine_rotation = $EngineRotationHelper.rotation + \
					$EngineRotationHelper/Engine.rotation
	engine_rotation = Basis(Quat(engine_rotation))
	
	rset("puppet_velocity", velocity)
	rset("puppet_transform", global_transform)
	rset("puppet_engine_rotation", engine_rotation)
	
	rpc("swing", is_swinging)
	if is_crashed:
		rset("crashbike_puppet_transform", crash_bike.global_transform)
	
#	if !rset_twentieth_timer.time_left:
#		rset("puppet_velocity", velocity)
#		rset_twentieth_timer.start(0.05)
#
#		rpc("swing", is_swinging)
##		print("RSet: Twentieth")
#
#	if !rset_quarter_timer.time_left:
#		rset("puppet_transform", global_transform)
#		rset("puppet_engine_rotation", engine_rotation)
#		rset_quarter_timer.start(0.25)
##		print("RSet: Quarter")


func check_lap_number() -> void:
	if lap_number > Network.multiplayer_lap_amount:
		Network.player_finished()
	else:
		HUD.set_lap(lap_number)


func _crash() -> void:
	._crash()
	rpc("set_crashed", true)


func _crash_finished() -> void:
	._crash_finished()
	rpc("set_crashed", false)
