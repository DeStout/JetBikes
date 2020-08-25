extends Control

onready var single_player_menu : ColorRect = $MenuFrame/SinglePlayerMenu
onready var online_menu : ColorRect = $MenuFrame/OnlineMenu
onready var options_menu : ColorRect = $MenuFrame/OptionsMenu

const MAIN_MENU_DEFAULT_POSITION : int = 256
const MAIN_MENU_OPTIONS_POSITION : int = 32

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	single_player_menu.get_node("Buttons/CancelButton") \
		.connect("pressed", self, "return_to_main")
	online_menu.get_node("Buttons/CancelButton") \
		.connect("pressed", self, "return_to_main")
	options_menu.get_node("Buttons/CancelButton") \
		.connect("pressed", self, "return_to_main")
	
func _toggle_single_player_menu() -> void:
	if $MenuFrame/MainFrame/MainPanel/SoloButton.pressed:
		_clear_options()
		$MenuFrame/SinglePlayerMenu.visible = true
		$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
		$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_OPTIONS_POSITION
	else:
		return_to_main()
	
func _toggle_online_menu() -> void:
	if $MenuFrame/MainFrame/MainPanel/OnlineButton.pressed:
		_clear_options()
		$MenuFrame/OnlineMenu.visible = true
		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
		$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_OPTIONS_POSITION
	else:
		return_to_main()
	
func _toggle_options_menu() -> void:
	if $MenuFrame/MainFrame/MainPanel/OptionsButton.pressed:
		_clear_options()
		$MenuFrame/OptionsMenu.visible = true
		$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
		$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
		$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_OPTIONS_POSITION
	else:
		return_to_main()
	
func return_to_main():
	_clear_options()
	$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
	$MenuFrame/MainFrame/MainPanel/OnlineButton.pressed = false
	$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
	$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_DEFAULT_POSITION

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
	
func _clear_options() -> void:
	$MenuFrame/SinglePlayerMenu.visible = false
	$MenuFrame/OnlineMenu.visible = false
	$MenuFrame/OptionsMenu.visible = false
	$MenuFrame/OptionsMenu.reset_settings()
