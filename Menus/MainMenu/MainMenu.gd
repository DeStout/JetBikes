extends Control

onready var single_player_menu : Control = $MenuFrame/SinglePlayerMenu
onready var online_menu : Control = $MenuFrame/OnlineMenu
onready var controls_menu : Control = $MenuFrame/ControlsMenu
onready var options_menu : Control = $MenuFrame/OptionsMenu

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if not OS.is_debug_build():
		$MenuFrame/ClientBtn.free()


func _on_ClientBtn_pressed():
	OS.execute(OS.get_executable_path(), [], false)


func _toggle_single_player_menu() -> void:
	if $MenuFrame/MainFrame/MainPanel/SoloButton.pressed:
		_clear_options()
		$MenuFrame/SinglePlayerMenu.visible = true
		$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/ControlsButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
	else:
		return_to_main()


func _toggle_online_menu() -> void:
	if $MenuFrame/MainFrame/MainPanel/OnlineButton.pressed:
		_clear_options()
		online_menu.visible = true
		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/ControlsButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
	else:
		return_to_main()


func _toggle_controls_menu() -> void:
	if $MenuFrame/MainFrame/MainPanel/ControlsButton.pressed:
		_clear_options()
		$MenuFrame/ControlsMenu.visible = true
		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
	else:
		return_to_main()


func _toggle_options_menu() -> void:
	if $MenuFrame/MainFrame/MainPanel/OptionsButton.pressed:
		_clear_options()
		options_menu.visible = true
		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/ControlsButton.pressed = false
	else:
		return_to_main()


func return_to_main():
	_clear_options()
	$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
	$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
	$MenuFrame/MainFrame/MainPanel/ControlsButton.pressed = false
	$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _clear_options() -> void:
	single_player_menu.visible = false
	online_menu.visible = false
	controls_menu.visible = false
	options_menu.visible = false
	options_menu.reset_settings()
