extends Control

var max_laps : String


func _process(delta):
	$FPS.text = "FPS: " + str(Engine.get_frames_per_second())


func set_max_laps(new_max_laps : int) -> void:
	max_laps = str(new_max_laps)
	$LapLabel.text = ("Lap: ~/" + str(max_laps))


func setup_minimap(new_minimap : Texture, new_minimap_camera : Camera, new_players : Array) -> void:
	$Minimap.texture = new_minimap
	$Minimap.minimap_camera = new_minimap_camera
	$Minimap.players = new_players


func set_speedometer(new_speed : float):
#	$SpeedBar.value = new_speed
	$Speed.text = str(int(new_speed))


func set_boost(new_boost : float):
	$BoostBar.value = new_boost


func set_lap(new_lap : int):
	if Globals.race_on_going:
		$LapLabel.text = ("Lap: " + str(new_lap) + "/" + max_laps)


func set_placement(new_placement : int):
	if Globals.race_on_going:
		$PlaceLabel.text = str(new_placement)


func set_arrow_angle(new_angle : float):
	$ArrowView/Arrow/ArrowMesh.rotation.y = new_angle


func set_race_notice(new_text = "", is_visible = false):
	$RaceNotice.text = new_text
	$RaceNotice.visible = is_visible
