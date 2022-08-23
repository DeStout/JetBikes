extends Spatial

onready var main_menu : GridContainer = $Control/MainMenu
onready var single_player_menu : Control = $Control/SinglePlayerMenu
#onready var online_menu : Control = $Control/OnlineMenu
onready var controls_menu : Control = $Control/ControlsMenu
onready var options_menu : Control = $Control/OptionsMenu

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if not OS.is_debug_build():
		$MenuFrame/ClientBtn.visible = false


#func _on_ClientBtn_pressed():
#	OS.execute(OS.get_executable_path(), [], false)


func _single_player_menu() -> void:
	main_menu.visible = false
	single_player_menu.visible = true


func _options_menu() -> void:
	main_menu.visible = false
	options_menu.visible = true


func _return_to_main() -> void:
	main_menu.visible = true
	single_player_menu.visible = false
	options_menu.visible = false
	controls_menu.visible = false


func _on_QuitButton_pressed() -> void:
	get_tree().quit()

#
#
#func _toggle_online_menu() -> void:
#	if $MenuFrame/MainFrame/MainPanel/OnlineButton.pressed:
#		_clear_options()
#		online_menu.visible = true
#		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
#		$MenuFrame/MainFrame/MainPanel/ControlsButton.pressed = false
#		$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
#	else:
#		return_to_main()
#
#
#func _toggle_controls_menu() -> void:
#	if $MenuFrame/MainFrame/MainPanel/ControlsButton.pressed:
#		_clear_options()
#		$MenuFrame/ControlsMenu.visible = true
#		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
#		$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
#		$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
#	else:
#		return_to_main()
#
#
#func _toggle_options_menu() -> void:
#	if $MenuFrame/MainFrame/MainPanel/OptionsButton.pressed:
#		_clear_options()
#		options_menu.visible = true
#		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
#		$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
#		$MenuFrame/MainFrame/MainPanel/ControlsButton.pressed = false
#	else:
#		return_to_main()
#
#
#func return_to_main():
#	_clear_options()
#	$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
#	$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
#	$MenuFrame/MainFrame/MainPanel/ControlsButton.pressed = false
#	$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
