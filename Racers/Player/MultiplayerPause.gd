extends PauseMenu


func _toggle_pause():
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_close_menus()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = !visible


func _quit_race():
	# Signals to MultiplayerManager
	emit_signal("leave_race")
