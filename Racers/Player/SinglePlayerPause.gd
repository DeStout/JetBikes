extends PauseMenu


func _toggle_pause():
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_close_menus()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = !get_tree().paused
	visible = !visible


func _quit_race():
	get_tree().paused = false
	# Signals to Track
	emit_signal("leave_race")
