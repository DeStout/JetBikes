extends Node2D

func on_ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Quit_Button_pressed():
	get_tree().quit()
