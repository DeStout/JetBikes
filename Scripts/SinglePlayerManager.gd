extends CanvasLayer

var current_track = null
	
func _process(delta) -> void:
	if $StartTimer.time_left:
		$HUD/RaceNotice.text = "%d" % ($StartTimer.time_left + 1)

func setup_race(var new_track) -> void:
	current_track = new_track
	current_track.connect("ready", self, "track_ready")
	add_child(current_track)
	
	_reset_HUD()
	
func _reset_HUD() -> void:
	$HUD/RaceNotice.text = ""
	$HUD/RaceNotice.visible = true
	$HUD/PlaceLabel.text = ""
	$HUD/LapLabel.text = ("Lap: -/" + str(Globals.laps_number))
	$HUD.visible = true

func track_ready() -> void:
	$MusicPlayer.play()
	$StartTimer.start()
	
func _start_race() -> void:
	$HUD/RaceNotice.visible = false
	current_track.start_race()

func finish_race() -> void:
	$HUD/RaceNotice.visible = true
	$HUD/RaceNotice.text = "Finished!"
	current_track.finish_race()
	$EndTimer.start()

func end_race():
	$HUD.visible = false
	$PauseMenu.visible = false
	$StartTimer.stop()
	$EndTimer.stop()
	$MusicPlayer.stop()
	current_track.queue_free()
	current_track = null
	Globals.game.return_to_main_menu()

func set_player_placement(new_placement : int) -> void:
	if current_track.race_on_going:
		$HUD/PlaceLabel.text = str(new_placement)

func set_player_lap(new_lap_number : int) -> void:
	if current_track.race_on_going:
		$HUD/LapLabel.text = ("Lap: " + str(new_lap_number) + "/" + str(Globals.laps_number))
		
func set_speedometer(new_speed : float) -> void:
	$HUD/SpeedBar.value = new_speed

func set_boost(new_boost : float) -> void:
	$HUD/BoostBar.value = new_boost

func setup_minimap(new_minimap : Texture, new_minimap_camera : Camera, new_players : Array) -> void:
	$HUD/MinimapContainer/Minimap.texture = new_minimap
	$HUD/MinimapContainer/Minimap.minimap_camera = new_minimap_camera
	$HUD/MinimapContainer/Minimap.players = new_players
