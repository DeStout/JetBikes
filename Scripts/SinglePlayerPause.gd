extends Control

func _input(event) -> void:
	if event.is_action_pressed("Pause"):
		if Globals.game.single_player_manager.current_track != null:
			_toggle_pause()

func _toggle_pause():
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = !get_tree().paused
	visible = !visible

func _quit_race():
	get_tree().paused = false
	Globals.game.single_player_manager.end_race()
