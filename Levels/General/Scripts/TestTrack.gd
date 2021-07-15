extends Spatial

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PauseMenu.connect("end_race", self, "end_race")

func end_race():
	get_tree().quit()
