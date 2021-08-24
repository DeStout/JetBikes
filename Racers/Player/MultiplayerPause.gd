extends PauseMenu


func _toggle_pause():
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_close_options_menu()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = !visible


func _quit_race():
	# Signals to OnlineMultiplayerManager
	emit_signal("leave_race")
