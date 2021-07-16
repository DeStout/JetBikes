extends CanvasLayer

signal return_to_main

var current_track = null
	
func _process(delta) -> void:
	if $StartTimer.time_left and current_track is TrackBasic:
		current_track.get_node("Players").player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)

func setup_race(var new_track) -> void:
	current_track = new_track.instance()
	if current_track is TrackBasic:
		current_track.connect("ready", self, "track_ready")
		current_track.connect("race_finished", self, "finish_race")
	add_child(current_track)

func track_ready() -> void:
	$MusicPlayer.play()
	$StartTimer.start()
	
func _start_race() -> void:
	current_track.start_race()

func finish_race() -> void:
	$EndTimer.start()

func _end_race():
	$PauseMenu.visible = false
	$StartTimer.stop()
	$EndTimer.stop()
	$MusicPlayer.stop()
	current_track.queue_free()
	current_track = null
	emit_signal("return_to_main")
