extends Spatial

onready var main_menu : GridContainer = $Menu/MainMenu
onready var single_player_menu : Control = $Menu/SinglePlayerMenu
onready var online_menu : Control = $Menu/OnlineMenu
onready var controls_menu : Control = $Menu/ControlsMenu
onready var options_menu : Control = $Menu/OptionsMenu

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if not OS.is_debug_build():
		$MenuFrame/ClientBtn.visible = false


func _new_client():
	OS.execute(OS.get_executable_path(), [], false)


func _single_player_menu() -> void:
	main_menu.visible = false
	single_player_menu.visible = true


func _multiplayer_menu() -> void:
	main_menu.visible = false
	online_menu.visible = true


func _options_menu() -> void:
	main_menu.visible = false
	options_menu.visible = true


func _controls_menu() -> void:
	main_menu.visible = false
	controls_menu.visible = true


func return_to_main() -> void:
	main_menu.visible = true
	single_player_menu.visible = false
	online_menu.visible = false
	options_menu.visible = false
	controls_menu.visible = false


func hide_all() -> void:
	main_menu.visible = false
	single_player_menu.visible = false
	online_menu.visible = false
	options_menu.visible = false
	controls_menu.visible = false



func _on_QuitButton_pressed() -> void:
	get_tree().quit()
