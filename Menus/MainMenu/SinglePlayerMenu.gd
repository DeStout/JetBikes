extends Control

signal setup_single_player_race

var solo_lap_amount : int = Globals.DEFAULT_LAP_NUMBER
var solo_NPC_amount : int = Globals.DEFAULT_NPC_NUMBER
var level_select : int = Globals.DEFAULT_LEVEL

var current_focus : Control = null


func _ready():
	set_process_input(false)

	$Level/LevelName.text = Globals.level_dict_keys[Globals.DEFAULT_LEVEL]
	$Laps/NumLaps.text = str(solo_lap_amount)
	$NPCs/NumNPCs.text = str(solo_NPC_amount)
	$ColorPicker.color = Globals.player_color


func _hide_show() -> void:
	set_process_input(visible)
	yield(get_tree(), "idle_frame")

	if Input.get_connected_joypads().size():
		if current_focus == null:
			current_focus = $Buttons/RaceButton
		current_focus.grab_focus()
		yield(get_tree(), "idle_frame")


func _input(event : InputEvent) -> void:
	if Input.get_connected_joypads().size():
		if !$ColorPicker.pressed:
			if Input.is_action_just_pressed("ui_up") or (event is InputEventJoypadMotion and \
									event.axis == JOY_AXIS_1 and event.axis_value == -1):
					current_focus = current_focus.get_node(current_focus.focus_neighbour_top)
					yield(get_tree(), "idle_frame")
			elif Input.is_action_just_pressed("ui_left") or (event is InputEventJoypadMotion and \
									event.axis == JOY_AXIS_0 and event.axis_value == -1):
					current_focus = current_focus.get_node(current_focus.focus_neighbour_left)
					yield(get_tree(), "idle_frame")
			elif Input.is_action_just_pressed("ui_right") or (event is InputEventJoypadMotion and \
									event.axis == JOY_AXIS_0 and event.axis_value == 1):
					current_focus = current_focus.get_node(current_focus.focus_neighbour_right)
					yield(get_tree(), "idle_frame")
			elif Input.is_action_just_pressed("ui_down") or (event is InputEventJoypadMotion and \
									event.axis == JOY_AXIS_1 and event.axis_value == 1):
					current_focus = current_focus.get_node(current_focus.focus_neighbour_bottom)
					yield(get_tree(), "idle_frame")
			current_focus.grab_focus()

		if event is InputEventJoypadButton:
			if Input.is_action_just_pressed("ui_accept"):
				if current_focus is Button:
					print(current_focus.name)
					current_focus.emit_signal("pressed")
			elif !$ColorPicker.pressed and event.is_action_pressed("ui_cancel"):
				$Buttons/BackButton.emit_signal("button_down")


func _process(delta: float) -> void:
	if $ColorPicker.pressed:
		if abs(Input.get_joy_axis(0, 3)) > InputMap.action_get_deadzone("CamLeft"):
			var joy_str := Input.get_action_strength("CamDown") - Input.get_action_strength("CamUp")
			$ColorPicker.color.h = clamp($ColorPicker.color.h + (joy_str * delta), 0.0, 1.0)

		if abs(Input.get_joy_axis(0, 0)) > InputMap.action_get_deadzone("StrifeLeft"):
			var joy_str := Input.get_action_strength("StrifeRight") - Input.get_action_strength("StrifeLeft")
			$ColorPicker.color.s = clamp($ColorPicker.color.s + (joy_str * delta), 0.0, 1.0)

		if abs(Input.get_joy_axis(0, 1)) > InputMap.action_get_deadzone("Accelerate"):
			var joy_str := Input.get_action_strength("Accelerate") - Input.get_action_strength("Reverse")
			$ColorPicker.color.v = clamp($ColorPicker.color.v + (joy_str * delta), 0.0, 1.0)



func _start_race():
	Globals.level = level_select
	Globals.laps_number = solo_lap_amount
	Globals.NPC_number = solo_NPC_amount
	Globals.is_multiplayer = false
	# Emits to Game
	emit_signal("setup_single_player_race")


func _select_color(new_color : Color) -> void:
	Globals.player_color = new_color


func _level_select_left():
	level_select -= 1
	if level_select < 0:
		level_select = Globals.level_dict_keys.size() - 1
	$Level/LevelName.text = Globals.level_dict_keys[level_select]


func _level_select_right():
	level_select += 1
	if level_select > Globals.level_dict_keys.size() - 1:
		level_select = 0
	$Level/LevelName.text = Globals.level_dict_keys[level_select]


func _decrease_lap_amount():
	solo_lap_amount -= 1
	if solo_lap_amount < Globals.MIN_LAP_NUMBER:
		solo_lap_amount = Globals.MAX_LAP_NUMBER
	$Laps/NumLaps.text = str(solo_lap_amount)


func _increase_lap_amount():
	solo_lap_amount += 1
	if solo_lap_amount > Globals.MAX_LAP_NUMBER:
		solo_lap_amount = Globals.MIN_LAP_NUMBER
	$Laps/NumLaps.text = str(solo_lap_amount)


func _decrease_NPC_amount():
	solo_NPC_amount -= 1
	if solo_NPC_amount < Globals.MIN_NPC_NUMBER:
		solo_NPC_amount = Globals.MAX_NPC_NUMBER
	$NPCs/NumNPCs.text = str(solo_NPC_amount)


func _increase_NPC_amount():
	solo_NPC_amount += 1
	if solo_NPC_amount > Globals.MAX_NPC_NUMBER:
		solo_NPC_amount = Globals.MIN_NPC_NUMBER
	$NPCs/NumNPCs.text = str(solo_NPC_amount)