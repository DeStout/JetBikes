extends Spatial

signal track_ready

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	emit_signal("track_ready", $Player.pause_menu)

func end_race():
	get_tree().quit()
