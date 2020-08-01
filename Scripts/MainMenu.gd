extends Control

const MAIN_PANEL_DEFAULT_POSITION = 288
const MAIN_PANEL_OPTIONS_POSITION = 64

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_Solo_Button_pressed():
#	get_tree().change_scene("res://Scenes/TestTrack.tscn")
	$MenuFrame/MainPanel.rect_position.x = MAIN_PANEL_OPTIONS_POSITION
	$MenuFrame/MainPanel/Solo_Button.pressed = true

func _on_Quit_Button_pressed():
	get_tree().quit()
