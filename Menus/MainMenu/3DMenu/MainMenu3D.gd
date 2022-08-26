extends Spatial

onready var main_menu : GridContainer = $Menu/MainMenu
onready var single_player_menu : Control = $Menu/SinglePlayerMenu
onready var online_menu : Control = $Menu/OnlineMenu
onready var controls_menu : Control = $Menu/ControlsMenu
onready var options_menu : Control = $Menu/OptionsMenu

onready var current_focus : Control = main_menu.get_node("SinglePlayerButton")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if not OS.is_debug_build():
		$MenuFrame/ClientBtn.visible = false


func _hide_show_main_menu() -> void:
	set_process_input(main_menu.visible)
	yield(get_tree(), "idle_frame")

	if main_menu.visible:
		if Input.get_connected_joypads().size():
			if current_focus == null:
				main_menu.get_node("SinglePlayerButton")
			current_focus.grab_focus()


func _input(event: InputEvent) -> void:
	if Input.get_connected_joypads().size():
#		if (event is InputEventJoypadButton and event.button_index == 12 and event.pressed == true) or \
		if event.is_action_pressed("ui_up") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_1 and event.axis_value == -1):
			current_focus = current_focus.get_node(current_focus.focus_previous)
			yield(get_tree(), "idle_frame")
		if event.is_action_pressed("ui_down") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_1 and event.axis_value == 1):
			current_focus = current_focus.get_node(current_focus.focus_next)
			yield(get_tree(), "idle_frame")

		current_focus.grab_focus()

		if event is InputEventJoypadButton and event.is_action_pressed("ui_accept"):
			current_focus.emit_signal("pressed")


func set_racer_color(color : Color) -> void:
	pass


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
