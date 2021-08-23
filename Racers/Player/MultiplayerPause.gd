extends PauseMenu


func _toggle_pause():
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_close_options_menu()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = !visible


func _quit_race():
	Network.leave_race(get_tree().get_network_unique_id())
	# Signals to OnlineMultiplayerManager
	._quit_race()
