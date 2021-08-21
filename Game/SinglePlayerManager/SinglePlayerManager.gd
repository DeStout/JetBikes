extends Node

signal return_to_main

var current_track = null


func setup_race(var new_track) -> void:
	current_track = new_track.instance()
	if current_track is Track:
		current_track.connect("race_finished", self, "finish_race")
	current_track.connect("track_ready", self, "track_ready")
	add_child(current_track)


func track_ready(pause_menu : Control) -> void:
	if current_track is Track:
		pass
	

func finish_race() -> void:
	$EndTimer.start()


