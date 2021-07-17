extends Spatial

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func end_race():
	get_tree().quit()
