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
	$HUD/PlaceLabel.text = ""
	$HUD/LapLabel.text = ("Lap: -/" + str(Globals.laps_number))
	$HUD.visible = true

func toggle_pause() -> void:
	get_tree().pause

func track_ready() -> void:
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
	current_track.queue_free()
	current_track = null
	Globals.game.return_to_main_menu()
	$StartTimer.stop()
	$EndTimer.stop()

func set_player_placement(new_placement : int) -> void:
	if current_track.race_on_going:
		$HUD/PlaceLabel.text = str(new_placement)

func set_player_lap(new_lap_number : int) -> void:
	if current_track.race_on_going:
		$HUD/LapLabel.text = ("Lap: " + str(new_lap_number) + "/" + str(Globals.laps_number))
