extends Control

onready var single_player_menu : ColorRect = $MenuFrame/SinglePlayerMenu
onready var options_menu : ColorRect = $MenuFrame/OptionsMenu

const MAIN_MENU_DEFAULT_POSITION : int = 256
const MAIN_MENU_OPTIONS_POSITION : int = 32

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	single_player_menu.get_node("Buttons/CancelButton") \
		.connect("pressed", self, "single_player_cancel")
	options_menu.get_node("Buttons/CancelButton") \
		.connect("pressed", self, "options_cancel")
	
func _open_solo_player_menu() -> void:
	if !$MenuFrame/SinglePlayerMenu.visible:
		_clear_options()
	$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_OPTIONS_POSITION
	$MenuFrame/SinglePlayerMenu.visible = true
	$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = true

func single_player_cancel() -> void:
	_clear_options()
	$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_DEFAULT_POSITION
	
func _open_options_menu() -> void:
	if !$MenuFrame/OptionsMenu.visible:
		_clear_options()
	$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_OPTIONS_POSITION
	$MenuFrame/OptionsMenu.visible = true
	$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = true

func options_cancel() -> void:
	_clear_options()
	$MenuFrame/MainFrame.rect_position.x = MAIN_MENU_DEFAULT_POSITION

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
	
func _clear_options() -> void:
	$MenuFrame/SinglePlayerMenu.visible = false
	$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false
	
	$MenuFrame/OptionsMenu.visible = false
	$MenuFrame/MainFrame/MainPanel/OptionsButton.pressed = false
	
	$MenuFrame/OptionsMenu.reset_settings()
